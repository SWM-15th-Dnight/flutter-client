import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_client/services/auth_service.dart';

class FBUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final GoogleSignInAccount? googleSignInAccount;
  final Map<String, String>? authHeaders;
  final String? idToken;

  const FBUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.googleSignInAccount,
    this.authHeaders,
    this.idToken,
  });

  String getIdToken() {
    return FBAuthService().getCurrentUser()?.getIdToken() ?? '';
  }

  Future<Map<String, String>> getAuthHeader() {
    return FBAuthService().getAuthHeader();
  }

  factory FBUser.fromGoogleSignInAccount(GoogleSignInAccount account,
      {Map<String, String>? authHeaders, String? idToken}) {
    return FBUser(
      uid: account.id,
      email: account.email,
      displayName: account.displayName,
      photoURL: account.photoUrl,
      googleSignInAccount: account,
      authHeaders: authHeaders,
      idToken: idToken,
    );
  }
}

extension FirebaseUserExtension on User {
  FBUser toFBUser({
    GoogleSignInAccount? googleSignInAccount,
    Map<String, String>? authHeaders,
    String? idToken,
  }) {
    return FBUser(
      uid: uid,
      email: email!,
      displayName: displayName,
      photoURL: photoURL,
      googleSignInAccount: googleSignInAccount,
      authHeaders: authHeaders,
      idToken: idToken,
    );
  }

  FBUser fromGoogleSignInAccount(GoogleSignInAccount account) {
    return FBUser.fromGoogleSignInAccount(account);
  }
}
