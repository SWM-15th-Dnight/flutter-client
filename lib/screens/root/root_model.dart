import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/services/user_service.dart';

class RootModel {
  final UserService userService;

  RootModel(this.userService);

  // Stream<FBUser?> getUserStream() {
  //   return userService.getUserStream();
  // }
  //
  // bool isSignedIn() {
  //   return userService.isSignedIn();
  // }
}
