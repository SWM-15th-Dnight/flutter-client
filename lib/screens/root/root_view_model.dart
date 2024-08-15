import 'package:flutter/material.dart';
import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/screens/root/root_model.dart';
import 'package:mobile_client/services/user_service.dart';

class RootViewModel extends ChangeNotifier {
  final RootModel _model;

  RootViewModel() : _model = RootModel(UserService());

  // Stream<FBUser?> getUserStream() {
  //   return _model.getUserStream();
  // }
  //
  // bool isSignedIn() {
  //   return _model.isSignedIn();
  // }
}
