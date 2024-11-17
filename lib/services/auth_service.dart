import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_client/common/component/snackbar_helper.dart';
import 'package:mobile_client/entities/utils.dart';
import 'package:mobile_client/services/dio_client.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/const/data.dart';

final authServiceProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class FBAuthService {
  FBAuthService();

  final dio = Dio();

  final _auth = FirebaseAuth.instance;
  Map<String, String>? _authHeaders;

  Stream<User?> getUserStream() {
    return _auth.authStateChanges();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> getIdToken() async {
    return await getCurrentUser()?.getIdToken();
  }

  Future<Map<String, String>?> getAuthHeaders() async {
    if (_authHeaders != null) {
      return _authHeaders;
    }

    final prefs = await SharedPreferences.getInstance();
    final authHeadersJson = prefs.getString('authHeaders');
    if (authHeadersJson != null) {
      _authHeaders = Map<String, String>.from(jsonDecode(authHeadersJson));
    }
    return _authHeaders;
  }

  Future<void> _saveAuthHeaders(Map<String, String> authHeaders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authHeaders', jsonEncode(authHeaders));
  }

  Future<Map<String, dynamic>?> signUpWithEmailAndPassword(
      Map<String, dynamic> data) async {
    try {
      final Response<dynamic>? resp =
          await MainRequest().postRequest('/api/v1/auth/signup', data);
      print('resp: ${resp}');
      return jsonDecode(resp!.data) as Map<String, dynamic>;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithEmailAndPassword(
      Map<String, dynamic> data) async {
    final Response<dynamic>? resp;
    try {
      resp = await MainRequest().postRequest('/api/v1/auth/login', data);
      //print('auth_service: ${resp?.statusCode}');

      if (resp?.statusCode == 200) {
        print(resp?.data.runtimeType);
        return jsonDecode(resp?.data) as Map<String, dynamic>;
      } else if (resp?.statusCode == 422) {
        //print('Invalid data format: ${resp?.data}');
        return {'error': 'Invalid data format'};
      } else if (resp?.statusCode == 401) {
        //print('Invalid credentials: ${resp?.data}');
        return {'error': 'Invalid credentials'};
      } else {
        //print('Error: ${resp?.statusCode} - ${resp?.data}');
        return {'error': 'An error occurred'};
      }
    } catch (e) {
      //print(resp.data);
      print('Exception: ${e.toString()}');
      //print('${resp?.statusCode} - ${resp?.data}');
      return {'error': 'An exception occurred'};
    }
    return null;
  }

  Future<bool> checkToken() async {
    var accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    if (accessToken == null || refreshToken == null) {
      print('[auth_service.dart] checkToken(): null tokens');
      return false;
    }

    try {
      await dio.get(
        dotenv.env['BACKEND_MAIN_URL']! + '/colorSet/',
        options: Options(
          headers: {
            'authorization': 'Bearer $refreshToken',
          },
        ),
      );
    } catch (e) {
      try {
        Response login = await dio.post(
          dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/auth/login',
          data: {
            'email': await storage.read(key: USER_EMAIL_KEY),
            'password': await storage.read(key: USER_PASSWORD_KEY),
          },
        );
        await storage.write(
            key: ACCESS_TOKEN_KEY, value: login.data['accessToken']);
        await storage.write(
            key: REFRESH_TOKEN_KEY, value: login.data['refreshToken']);
        print('[auth_service.dart] checkToken(): tokens updated');
        return true;
      } catch (e) {
        print('[auth_service.dart] checkToken(): fail to update token:$e');
        return false;
      }
    }
    print('[auth_service.dart] checkToken(): tokens are valid');
    return true;
  }

  Future<Map<String, dynamic>?> signInWithGoogle(WidgetRef ref) async {
    const List<String> scopes = <String>[
      'email',
      'https://www.googleapis.com/auth/calendar',
    ];

    try {
      // Sign out from any existing Google account
      await GoogleSignIn(signInOption: SignInOption.standard).signOut();

      // Trigger the authentication flow
      GoogleSignInAccount? googleUser = await GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: scopes,
      ).signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소함
        return null;
      }

      // TODO.
      // _saveAuthHeaders(await googleUser!.authHeaders);

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        print('Firebase 인증 실패');
        return null;
      }

      // user.email, user,displayName, user.uid

      Map<String, String?> data = {
        'email': user.email,
        'password': user.uid,
      };

      setEmailPassword(user.email!, user.uid);

      Response response;

      try {
        print('Google 사용자 로그인 시도');
        print('data: $data');
        response = await DioClient()
            .post('${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/auth/login', data);
      } catch (e) {
        // 로그인 실패 시 회원가입 시도
        data = {
          'email': user.email,
          'name': user.displayName,
          'uid': user.uid,
          'gender': 'male',
          'phoneNumber': 'string',
        };

        response = await DioClient().post(
            '${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/auth/google', data);

        if (response.statusCode != 200) {
          print('Google 사용자 가입 실패');
          print(response.statusCode);
          print(response.data);
          return null;
        }

        // 회원가입 성공 시 로그인 재시도
        data = {
          'email': user.email,
          'password': user.uid,
        };

        response = await DioClient()
            .post('${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/auth/login', data);

        if (response.statusCode != 200) {
          print('Google 사용자 로그인 실패');
          print(response.statusCode);
          print(response.data);
          return null;
        }
      }

      ref.read(authServiceProvider.notifier).state = response.data;
      return response.data;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<UserCredential?> signInSilentlyWithGoogle() async {
    try {
      // Sign out from any existing Google account
      //await GoogleSignIn(signInOption: SignInOption.standard).signOut();

      const List<String> scopes = <String>[
        'email',
        'https://www.googleapis.com/auth/calendar',
      ];

      // Trigger the authentication flow
      GoogleSignInAccount? googleUser = await GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: scopes,
      ).signInSilently();

      if (googleUser != null) {
        _saveAuthHeaders(await googleUser!.authHeaders);

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        //print(googleAuth!.accessToken);

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        //print('User silently signed in with Google.');
        // Once signed in, return the UserCredential
        return await _auth.signInWithCredential(credential);
      } else {
        //print('No user signed in silently.');
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<bool?> signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider('microsoft.com');
      final String tenant = dotenv.env['MS_TENANT_ID']!;
      microsoftProvider.setCustomParameters({'tenant': tenant});

      final UserCredential userCredential;

      if (kIsWeb) {
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(microsoftProvider);
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> signOut() async {
    // 토큰 삭제
    await storage.delete(key: ACCESS_TOKEN_KEY);
    await storage.delete(key: REFRESH_TOKEN_KEY);
    // 계정 정보 삭제
    await storage.delete(key: USER_EMAIL_KEY);
    await storage.delete(key: USER_PASSWORD_KEY);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authHeaders');
    //await prefs.remove('profile_image_path');
    await prefs.remove('userName');

    await GoogleSignIn(signInOption: SignInOption.standard).signOut();
    return await FirebaseAuth.instance.signOut();
  }
}
