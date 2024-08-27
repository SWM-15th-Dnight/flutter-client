import 'package:flutter/material.dart';
import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/screens/signIn/sign_in_model.dart';
import 'package:mobile_client/services/auth_service.dart';

class SignInViewModel extends ChangeNotifier {
  final SignInModel _model;

  SignInViewModel() : _model = SignInModel(FBAuthService());

  // FBUser? currentUser() {
  //   return _model.currentUser();
  // }

  void signInWithGoogle() {
    _model.signInWithGoogle();
  }

  void signInWithMicrosoft() {
    _model.signInWithMicrosoft();
  }
}
