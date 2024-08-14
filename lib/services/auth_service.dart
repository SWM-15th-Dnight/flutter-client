import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mobile_client/entities/user.dart';

User? user;
String? idToken;
GoogleSignInAccount? googleUser;
Map<String, String>? authHeaders;

class FBAuthService {
  FBAuthService();

  /// 현재 사용자가 로그인되어 있는지 확인합니다.
  bool isSignedIn() {
    return getCurrentUser() != null;
  }

  /// 사용자 인증 상태 변화를 스트림으로 반환합니다.
  Stream<FBUser?> getUserStream() {
    print('getUserStream');
    return FirebaseAuth.instance.authStateChanges().map((User? user) {
      return user?.toFBUser(
        googleSignInAccount: googleUser,
        authHeaders: authHeaders,
        idToken: idToken,
      );
    });
  }

  /// 현재 인증된 사용자를 가져옵니다. (있다면)
  FBUser? getCurrentUser() {
    return FirebaseAuth.instance.currentUser?.toFBUser();
  }

  /// 현재 세션의 JWT 액세스 토큰을 가져옵니다.
  Future<String?>? getJWTToken() {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<Map<String, String>> getAuthHeader() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      idToken = await user.getIdToken();
      return {
        'Authorization': 'Bearer $idToken',
      };
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  Future<bool> signInWithGoogle() async {
    print('call check call check call check call check call check');
    try {
      // Sign out from any existing Google account
      await GoogleSignIn(signInOption: SignInOption.standard).signOut();

      const List<String> scopes = <String>[
        'email',
        'https://www.googleapis.com/auth/calendar',
      ];

      // Trigger the authentication flow
      googleUser = await GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: scopes,
      ).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((userCredential) async {
        // user = userCredential.user;
        // idToken = googleAuth?.idToken;
        idToken = await userCredential.user?.getIdToken();
        authHeaders = await googleUser?.authHeaders;
        userCredential.user?.toFBUser();

        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
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
    return await FirebaseAuth.instance.signOut();
  }
}
