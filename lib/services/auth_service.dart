import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/const/data.dart';

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

    // TODO. 로그아웃 시 둘 다 널인지 확인
    if (accessToken == null || refreshToken == null) {
      print('checkToken: null tokens!');
      return false;
    }

    var resp;
    var login;
    try {
      resp = await dio.get(
        dotenv.env['BACKEND_MAIN_URL']! + '/colorSet/',
        options: Options(
          headers: {
            'authorization': 'Bearer $refreshToken',
          },
        ),
      );
      print('/colorSet/ resp: $resp');
    } catch (e) {
      print('/colorSet/ error: $e');

      try {
        login = await dio.post(
          dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/auth/login',
          data: {
            'email': await storage.read(key: USER_EMAIL_KEY),
            'password': await storage.read(key: USER_PASSWORD_KEY),
          },
        );
        print('/auth/login resp: ${login.data}');

        await storage.write(
            key: ACCESS_TOKEN_KEY, value: login.data['accessToken']);
        await storage.write(
            key: REFRESH_TOKEN_KEY, value: login.data['refreshToken']);
        print('tokens updated!!!!!!!!!!!!!!!!!!!');
        return true;
      } catch (e) {
        print('/auth/login error: $e');
        print('checkToken: token update failed!');
        return false;
      }
    }
    return true;
  }

  Future<void> signInWithGoogle() async {
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
      ).signIn();

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

      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);

      Map<String, dynamic> data = {
        'email': getCurrentUser()?.email,
        'name': getCurrentUser()?.displayName,
        'uid': getCurrentUser()?.uid,
      };

      // Future<Map<String, dynamic>?> resp =
      //     MainRequest().postRequest('/api/v1/auth/google', data);
      // print('resp: ${resp}');
    } catch (e) {
      print(e.toString());
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
    await storage.delete(key: ACCESS_TOKEN_KEY);
    await storage.delete(key: REFRESH_TOKEN_KEY);
    await storage.delete(key: USER_EMAIL_KEY);
    await storage.delete(key: USER_PASSWORD_KEY);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authHeaders');
    //await prefs.remove('profile_image_path');

    await GoogleSignIn(signInOption: SignInOption.standard).signOut();
    return await FirebaseAuth.instance.signOut();
  }
}
