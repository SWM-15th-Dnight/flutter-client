import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_client/app_state.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double _buttonWidth = 185;
  double _borderRadius = 10.0;
  Color _buttonColor = ColorPalette.PRIMARY_COLOR[400]!;

  @override
  Widget build(BuildContext context) {
    return RootPage();
  }
  /*
  @override
  Widget build(BuildContext context) {
    // return RootPage();
    return SafeArea(
      child: Scaffold(
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 200),
            Center(
              child: Image.asset(
                'asset/img/logo/logo.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Calinify',
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 30),
            MouseRegion(
              onHover: (_) {
                setState(() {
                  _buttonWidth = MediaQuery.of(context).size.width;
                  _borderRadius = 0;
                  _buttonColor = ColorPalette.SECONDARY_COLOR[200]!;
                  // _buttonColor = Colors.transparent;
                });
              },
              onExit: (_) {
                setState(() {
                  _buttonWidth = 185;
                  _borderRadius = 10.0;
                });
              },
              // TODO: subtract PRIMARY_COLOR when hover
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: _buttonWidth,
                height: 40,
                decoration: BoxDecoration(
                  color: _buttonColor,
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
                // color: _buttonColor,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: show modal bottom sheet
                    // https://api.flutter.dev/flutter/material/showModalBottomSheet.html
                    print(
                        '${MediaQuery.of(context).size.width}, ${MediaQuery.of(context).size.height}');
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                            height: 200,
                            color: Colors.amber,
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Modal BottomSheet'),
                                ElevatedButton(
                                  child: const Text('Close BottomSheet'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            )));
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                  ),
                  child: Text(
                    '시작',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/
}

class RootPage extends StatefulWidget {
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  //var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    Widget page = Placeholder();

    /*
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        page = HomePage();
      } else {
        print('User is signed in!');
        page = SignInPage();
      }
    });
    */

    if (FirebaseAuth.instance.currentUser == null) {
      //print('User is currently signed out!');
      page = HomePage();
    } else {
      //print('User is signed in!');
      page = SignInPage();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ))
          ],
        ),
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('< HomePage >');
    var appState = context.watch<AppState>();

    final dio = Dio();

    // localhost
    final emulatorIp = '10.0.0.2:3000'; // Android
    final simulatorIp = '127.0.0.1:3000'; // iOS

    final ip =
        '172.16.101.108:3000'; // Platform.isIOS ? simulatorIp : emulatorIp;
    print('ip: $ip');

    return Material(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final rawString = 'bammer@calinify.com:muyaho';
              Codec<String, String> stringtoBase64 = utf8.fuse(base64);
              String token = stringtoBase64.encode(rawString);

              // final resp = await dio.post('http://$ip/auth/login',
              //     options: Options(headers: {
              //       'authorization': 'Basic $token',
              //     }));

              // print(resp.data);

              appState.signIn('google');
            },
            icon: SvgPicture.asset(
              'assets/images/google_logo.svg',
              width: 24,
              height: 24,
            ),
            label: Text('Google'),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () async {
              final refreshToken =
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImJhbW1lckBjYWxpbmlmeS5jb20iLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTcyMjA5NzcyNSwiZXhwIjoxNzIyMTg0MTI1fQ.AxoofdCYQ7XUIM0R9g3_9WfjyWBPk6SvFeCIhtWgQjQ';

              final resp = await dio.post('http://$ip/auth/token',
                  options: Options(headers: {
                    'authorization': 'Bearer $refreshToken',
                  }));

              print(resp.data);

              appState.signIn('microsoft');
            },
            icon: SvgPicture.asset(
              'assets/images/microsoft_logo.svg',
              width: 24,
              height: 24,
            ),
            label: Text('Microsoft로 계속하기'),
          ),
        ],
      )),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    print('< SignInPage >');
    User? signedUser = null;

    if (FirebaseAuth.instance.currentUser != null) {
      signedUser = FirebaseAuth.instance.currentUser;
    } else {
      print('Signed null currentUser error');
    }

    printLongString('idToken: ${idToken}');
    return Scaffold(
        appBar: AppBar(
          title: Text('Calinify'),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 3, 16),
              lastDay: DateTime.utc(2030, 3, 16),
              focusedDay: appState.focusedDay,
              calendarFormat: appState.calendarFormat,
              onPageChanged: (focusedDay) {
                appState.UpdateFocusedDay(focusedDay);
              },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('email: ${signedUser?.email}'),
                  SizedBox(height: 10),
                  Text('displayName: ${signedUser?.displayName}'),
                  SizedBox(height: 10),
                  Text('uid: ${signedUser?.uid}'),
                  SizedBox(height: 20),
                  //Text(
                  //    'idToken: ${idToken != null && idToken!.length > 20 ? "...${idToken!.substring(idToken!.length - 10)}" : idToken}'),
                  Text(
                    'idToken: ${idToken}',
                    style: TextStyle(fontSize: 8),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      appState.signOut();
                      //logger.d("test2: ${idToken}");
                    },
                    child: Text('로그아웃'),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
