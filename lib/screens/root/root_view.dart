import 'package:flutter/material.dart';
import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/screens/calendar/calendar_view.dart';
import 'package:mobile_client/screens/calendar/sfc_view.dart';
import 'package:mobile_client/screens/home/home_view.dart';
import 'package:mobile_client/screens/home/home_view_model.dart';
import 'package:mobile_client/screens/root/root_view_model.dart';
import 'package:mobile_client/screens/signIn/sign_in_view.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<RootViewModel>(context);

    return StreamBuilder(
        stream: viewModel.getUserStream(),
        builder: (BuildContext context, AsyncSnapshot<FBUser?> snapshot) {
          if (snapshot.data != null) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (BuildContext content) => HomeViewModel())
              ],
              child: CalendarView(),
            );
          } else {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (BuildContext content) => SignInViewModel())
              ],
              child: LoginScreen(),
            );
          }
        });
  }
}
