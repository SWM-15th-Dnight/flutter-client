import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/services/auth_service.dart';

class UserService {
  FBAuthService authService = FBAuthService();

  // FBUser? getCurrentUser() {
  //   return authService.getCurrentUser();
  // }
  //
  // Stream<FBUser?> getUserStream() {
  //   return authService.getUserStream();
  // }
  //
  // bool isSignedIn() {
  //   return authService.isSignedIn();
  // }

  Future<void> signOut() async {
    //await deleteFCMToken(fcmToken: "TODO: FCM 토큰을 가져오는 코드를 작성하세요.");
    return authService.signOut();
  }
}
