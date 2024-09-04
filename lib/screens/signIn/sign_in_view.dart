import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_client/common/component/service_name_text.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/common/layout/default_layout.dart';
import 'package:mobile_client/screens/calendar/main_calendar.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/const/data.dart';
import '../../widget/auth_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final FBAuthService _auth = FBAuthService();
  bool isEmailSignIn = false;
  String email = '';
  String password = '';

  // implicit animation
  bool _isLogoVisible = false;
  bool _isStartButtonVisible = false;

  @override
  void initState() {
    super.initState();

    // Set _isLogoVisible to true after the first build is completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLogoVisible = true;
      });

      Future.delayed(const Duration(milliseconds: 1700), () {
        setState(() {
          _isStartButtonVisible = true;
        });
      });
    });
  }

  void setEmailSignIn(bool value) {
    setState(() {
      isEmailSignIn = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInSet = MediaQuery.of(context).viewInsets.bottom;

    return DefaultLayout(
        child: SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: isEmailSignIn,
              child: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Container(
                  color: Colors.transparent,
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      BackButton(
                        onPressed: () {
                          setEmailSignIn(false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            //top: isEmailSignIn ? kToolbarHeight : 0,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: AnimatedOpacity(
                        opacity: _isLogoVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.decelerate,
                        child: _Logo(),
                      ),
                    ),
                    ServiceNameText(serviceName: 'Calinify'),
                    SizedBox(height: 0),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.decelerate,
                      child: isEmailSignIn
                          ? Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  child: AuthTextFormField(
                                    scrollPadding: bottomInSet / 2,
                                    textAlign: TextAlign.center,
                                    hintText: '이메일',
                                    onChanged: (String value) {
                                      email = value;
                                    },
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                  child: AuthTextFormField(
                                    scrollPadding: bottomInSet / 3,
                                    obscureText: true,
                                    textAlign: TextAlign.center,
                                    hintText: '비밀번호',
                                    onChanged: (String value) {
                                      password = value;
                                    },
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 40,
                      child: AnimatedOpacity(
                        opacity: _isStartButtonVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _StartButton(
                          isEmailSignIn: isEmailSignIn,
                          auth: _auth,
                          setEmailSignIn: setEmailSignIn,
                          email: email,
                          password: password,
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 50,
                        height: MediaQuery.of(context).size.height * 0.3),
                    //SizedBox(height: bottomInSet),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
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
      height: 40,
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
