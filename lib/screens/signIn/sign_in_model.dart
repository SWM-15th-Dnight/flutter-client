import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/services/auth_service.dart';

class SignInModel {
  final FBAuthService authService;
  SignInModel(this.authService);

  FBUser? currentUser() {
    return authService.getCurrentUser();
  }

  void signInWithGoogle() async {
    await authService.signInWithGoogle();
  }

  void signInWithMicrosoft() async {
    await authService.signInWithMicrosoft();
  }

  // void signInWithKakao() async {
  //   await authService.signInWithKakao(appScheme: "flutter-package-sample://");
  // }

  // void signInAnonymously() async {
  //   await authService.signInAnonymously();
  // }
}
