import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/screens/calendar/main_calendar.dart';
import 'package:mobile_client/screens/home/home_view_model.dart';
import 'package:mobile_client/screens/root/root_view_model.dart';
import 'package:mobile_client/screens/signIn/sign_in_view.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';

class RootView extends StatelessWidget {
  final FBAuthService auth;

  RootView({
    super.key,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    //var viewModel = Provider.of<RootViewModel>(context);

    return StreamBuilder(
      stream: auth.getUserStream(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.data != null) {
          return MainCalendar(auth: auth);
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
