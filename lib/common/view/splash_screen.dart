import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_client/common/component/loading_indicators.dart';
import 'package:mobile_client/common/component/service_name_text.dart';

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
      if (await _auth.checkToken()) {
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
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              ServiceNameText(
                serviceName: 'Calinify',
                textColor: Colors.white,
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: Center(child: LoadingIndicators(color: Colors.white)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
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
