import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/screens/home/home_model.dart';
import 'package:mobile_client/services/user_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeModel _model;

  HomeViewModel() : _model = HomeModel(UserService());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userUID() {
    return _model.user()?.uid ?? '-';
  }

  String userEmail() {
    return _model.user()?.email ?? '-';
  }

  String userDisplayName() {
    return _model.user()?.displayName ?? '-';
  }

  // TODO. Integrate it to FBUser class
  Future<String?> getIdToken() async {
    User? user = _auth.currentUser;
    return await user?.getIdToken();
  }
  // String? userIdToken() {
  //   return _model.user()?.getIdToken();
  // }

  Future<void> signOut() async {
    return await _model.signOut();
  }
}
