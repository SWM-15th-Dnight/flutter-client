import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FBAuthService {
  FBAuthService();

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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out from any existing Google account
      await GoogleSignIn(signInOption: SignInOption.standard).signOut();

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

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authHeaders');
    return await FirebaseAuth.instance.signOut();
  }
}
