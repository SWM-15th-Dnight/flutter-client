import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        Navigator.pushReplacement(
          context,
          FadePageRoute(
            builder: (context) => MainCalendar(auth: _auth),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          FadePageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SafeArea(
        child: Stack(
          children: [
            Container(
              color: ColorPalette.PRIMARY_COLOR[400]!,
            ),
            Transform.translate(
              offset: Offset(0, -20),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 100), // 서비스 명보다 위로 배치되도록
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                          text: '일정 입력을 ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                        TextSpan(
                          text: '간편',
                          style: TextStyle(
                              color: ColorPalette.SECONDARY_COLOR[400]!,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: '하게,',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                      ])),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ServiceNameText(
                      serviceName: 'Calinify',
                      textColor: Colors.white,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: LoadingIndicators(color: Colors.white),
                    ),
                  ),

                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.3,
                  //   child: Container(
                  //     color: Colors.transparent,
                  //   ),
                  // ),
                ],
              ),
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
