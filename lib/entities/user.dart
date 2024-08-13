import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_client/services/auth_service.dart';

class FBUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  //final String? idToken;

  const FBUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    //required this.idToken, // idToken = await user?.getIdToken();
  });

  String getIdToken() {
    return FBAuthService().getCurrentUser()?.getIdToken() ?? '';
  }
}

extension FirebaseUserExtension on User {
  FBUser toFBUser() {
    return FBUser(
        uid: uid, email: email!, displayName: displayName, photoURL: photoURL);
  }
}
