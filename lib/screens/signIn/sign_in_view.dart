import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/screens/calendar/main_calendar.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/const/data.dart';
import '../../widget/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final FBAuthService _auth = FBAuthService();
  bool isEmailSignIn = false;

  late AnimationController _controller;
  late Animation<double> _logoTitleAnimation;
  late Animation<double> _buttonAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isFirstTime = true;

  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1700),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _logoTitleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.1), // TODO.
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Debug. reload app to test first time
    prefs.remove('isFirstTime');
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      _controller.forward();
      await prefs.setBool('isFirstTime', false);
    } else {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  void setEmailSignIn(bool value) {
    setState(() {
      isEmailSignIn = value;
      // Slide animation
      if (isEmailSignIn) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.90,
            alignment: Alignment.center,
            child: _isFirstTime
                ? Stack(
                    children: [
                      PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: isEmailSignIn
                            ? AppBar(
                                leading: BackButton(
                                  onPressed: () {
                                    setEmailSignIn(false);
                                  },
                                ),
                                elevation: 0,
                              )
                            : Container(),
                      ),
                      Positioned(
                        top: 30,
                        left: 0,
                        right: 0,
                        child: FadeTransition(
                          opacity: _logoTitleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Logo(),
                              SizedBox(height: 20),
                              _Title(),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isEmailSignIn) ...[
                            const SizedBox(
                              height: 50,
                              width: double.infinity,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: CustomTextFormField(
                                textAlign: TextAlign.center,
                                hintText: '이메일',
                                onChanged: (String value) {
                                  email = value;
                                },
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: CustomTextFormField(
                                obscureText: true,
                                textAlign: TextAlign.center,
                                hintText: '비밀번호',
                                onChanged: (String value) {
                                  password = value;
                                },
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 10,
                            width: double.infinity,
                          ),
                          FadeTransition(
                            opacity: _buttonAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _StartButton(
                                isEmailSignIn: isEmailSignIn,
                                auth: _auth,
                                setEmailSignIn: setEmailSignIn,
                                email: email,
                                password: password,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : _buildLoginContent(),
          ),
        ),
      )),
    );
  }

  // removed FadeTransitions
  Widget _buildLoginContent() {
    print('never reached?????????????????????');
    return Stack(
      children: [
        PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: isEmailSignIn
              ? AppBar(
                  leading: BackButton(
                    onPressed: () {
                      setEmailSignIn(false);
                    },
                  ),
                  elevation: 0,
                )
              : Container(),
        ),
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Logo(),
              SizedBox(height: 20),
              _Title(),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isEmailSignIn) ...[
              const SizedBox(
                height: 50,
                width: double.infinity,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: '이메일',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: '비밀번호',
                ),
              ),
            ],
            const SizedBox(
              height: 10,
              width: double.infinity,
            ),
            SlideTransition(
              position: _slideAnimation,
              child: _StartButton(
                isEmailSignIn: isEmailSignIn,
                auth: _auth,
                setEmailSignIn: setEmailSignIn,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Calinify',
      style: TextStyle(
        fontFamily: 'Rockwell',
        fontWeight: FontWeight.bold,
        fontSize: 40,
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Align(
        alignment: Alignment.center,
        child: Image.asset(
          'asset/img/logo/logo.png',
          width: MediaQuery.of(context).size.width / 5 * 3,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  final FBAuthService auth;
  final bool isEmailSignIn;
  final Function(bool) setEmailSignIn;

  final String? email;
  final String? password;

  const _StartButton({
    required this.auth,
    required this.isEmailSignIn,
    required this.setEmailSignIn,
    this.email,
    this.password,
  });

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  Map<String, String?> data = {};

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, String?>> getEmailPassword() async {
    data = {
      'email': widget.email,
      'password': widget.password,
    };
    print(data);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.isEmailSignIn) {
            try {
              await getEmailPassword();
              final resp = await dio.post(
                dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/auth/login',
                data: data,
              );
              if (resp.statusCode == 200) {
                print(resp);

                // checked.
                // if (await storage.read(key: ACCESS_TOKEN_KEY) == null) {
                //   print('null ACCESS_TOKEN_KEY');
                // }

                await storage.write(key: USER_EMAIL_KEY, value: widget.email);
                await storage.write(
                    key: USER_PASSWORD_KEY, value: widget.password);
                await storage.write(
                    key: ACCESS_TOKEN_KEY, value: resp.data['accessToken']);
                await storage.write(
                    key: REFRESH_TOKEN_KEY, value: resp.data['refreshToken']);

                if (await widget.auth.checkToken()) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MainCalendar(auth: widget.auth)));
                } else {
                  print('sign_in_view: token update failled');
                }
              }
            } catch (e) {
              print('sign_in_view: $e');
              /*
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('서버와의 연결의 원활하지 않습니다.'),
                ),
              );
              */
            }
          } else {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 40,
                            height: 2,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAAAAAA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              //viewModel.signInWithGoogle();
                              await widget.auth.signInWithGoogle();
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MainCalendar(auth: widget.auth)));
                            },
                            icon: SvgPicture.asset(
                              'asset/img/logo/google_logo.svg',
                              width: 24,
                              height: 24,
                            ),
                            label: const Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: 'Google로 계속하기',
                                  style: TextStyle(
                                    color: Color(0xFFF7F8F9),
                                  ),
                                ),
                              ]),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorPalette.PRIMARY_COLOR[400]!,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              //viewModel.signInWithMicrosoft();
                              widget.setEmailSignIn(true);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            label: const Text(
                              '이메일로 계속하기',
                              style: TextStyle(
                                color: Color(0xFFF7F8F9),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorPalette.SECONDARY_COLOR[400]!,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0))),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          widget.isEmailSignIn ? '로그인' : '시작',
          style: TextStyle(
            color: ColorPalette.GRAY_COLOR[50]!,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
