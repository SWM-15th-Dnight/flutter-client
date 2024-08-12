import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/services/user_service.dart';

class HomeModel {
  final UserService userService;

  HomeModel(this.userService);

  Future<void> signOut() async {
    return await userService.signOut();
  }

  FBUser? user() {
    return userService.getCurrentUser();
  }
}
