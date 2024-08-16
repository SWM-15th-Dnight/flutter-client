import 'package:flutter/material.dart';

import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/common/layout/default_layout.dart';
import 'package:mobile_client/screens/calendar/main_calendar.dart';
import 'package:mobile_client/screens/root/root_view.dart';
import '../../screens/signIn/sign_in_view.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FBAuthService _auth = FBAuthService();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      if (await _auth.signInSilentlyWithGoogle() != null) {
        //print('SplashScreen to MainCalendar');
        Navigator.pushReplacement(
          context,
          FadePageRoute(
            builder: (context) => MainCalendar(auth: _auth),
          ), // Replace with your target screen
        );
      } else {
        //print('SplashScreen to LoginScreen');
        Navigator.pushReplacement(
          context,
          FadePageRoute(
            builder: (context) => LoginScreen(),
          ), // Replace with your target screen
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Calinify',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Rockwell',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                )),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// TODO.
class FadePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  FadePageRoute({
    required this.builder,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}
