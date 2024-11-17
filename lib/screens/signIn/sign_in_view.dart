import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_client/common/component/custom_app_bar.dart';
import 'package:mobile_client/common/component/service_name_text.dart';
import 'package:mobile_client/common/component/snackbar_helper.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/common/layout/default_layout.dart';
import 'package:mobile_client/riverpod/state_provider.dart';
import 'package:mobile_client/screens/calendar/main_calendar.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:mobile_client/services/dio_client.dart';
import 'package:mobile_client/widget/custom_modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/const/data.dart';
import '../../entities/utils.dart';
import '../../widget/rounded_input_box.dart';

String email = '';
String displayedEmail = '';
String password = '';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final FBAuthService _auth = FBAuthService();
  bool isEmailSignIn = false;

  // TextFormField
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isEmailFocused = true;
  bool _isPasswordVisible = false;

  // form validation
  final _formKey = GlobalKey<FormState>();

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

      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _isStartButtonVisible = true;
        });
      });
    });

    // TextFormField
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _emailController.text = email;
          _isLogoVisible = false;
        });
      } else {
        setState(() {
          _emailController.text = _getDisplayEmail(email);
          _isLogoVisible = true;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _isLogoVisible = false;
        });
      } else {
        setState(() {
          _isLogoVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void setEmailSignIn(bool value) {
    setState(() {
      isEmailSignIn = value;
    });
  }

  String _getDisplayEmail(String email) {
    if (email.length > 20) {
      return email.substring(0, 17) + "...";
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(signInValidateProvider);
    final bottomInSet = MediaQuery.of(context).viewInsets.bottom;

    return DefaultLayout(
        child: SafeArea(
      child: Stack(
        children: [
          // Background Color
          Container(
            color: ColorPalette.GRAY_COLOR[50]!,
          ),
          // AppBar
          CustomAppBar(
            isVisible: isEmailSignIn,
            leftWidget: IconButton(
              icon: Icon(Icons.arrow_back),
              //iconSize: 24.0, // default 24.0
              onPressed: () {
                FocusScope.of(context).unfocus();
                _emailController.clear();
                email = '';
                password = '';
                setEmailSignIn(false);
              },
            ),
          ),

          Transform.translate(
            offset: Offset(0, -20),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.only(bottom: 300),
                    child: AnimatedOpacity(
                      opacity: _isLogoVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.decelerate,
                      child: _Logo(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.only(bottom: 0),
                    child: ServiceNameText(
                      serviceName: 'Calinify',
                      textColor: Colors.black,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 132 + 20),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.decelerate,
                      child: isEmailSignIn
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  height: 36,
                                  child: RoundedInputBox(
                                    // autofocus: true,
                                    scrollPadding: bottomInSet / 2,
                                    focusNode: _emailFocusNode,
                                    controller: _emailController,
                                    textAlign: TextAlign.center,
                                    hintText: '이메일',
                                    maxLength: 40,
                                    onChanged: (String value) async {
                                      setState(() {
                                        email = value;
                                      });
                                    },
                                    suffixIcon: Icons.clear,
                                    onIconPressed: () {
                                      setState(() {
                                        _emailController.clear();
                                        email = '';
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  height: 36,
                                  child: RoundedInputBox(
                                    scrollPadding: bottomInSet / 3,
                                    focusNode: _passwordFocusNode,
                                    obscureText: !_isPasswordVisible,
                                    textAlign: TextAlign.center,
                                    hintText: '비밀번호',
                                    maxLength: 20,
                                    onChanged: (String value) async {
                                      password = value;
                                    },
                                    suffixIcon: _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    onIconPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                ),
                // TODO. 이메일 입력 및 비밀번호 형식 경고 문구

                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 264 + 20),
                    child: AnimatedOpacity(
                      opacity: isEmailSignIn ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        provider,
                        style: TextStyle(
                          color: ColorPalette.SECONDARY_COLOR[400]!,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.center,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.only(
                        top: isEmailSignIn ? 350 + 20 : 120 + 20),
                    child: AnimatedOpacity(
                      opacity: _isStartButtonVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _StartButton(
                        isEmailSignIn: isEmailSignIn,
                        auth: _auth,
                        setEmailSignIn: setEmailSignIn,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 432 + 20),
                    child: AnimatedOpacity(
                      opacity: isEmailSignIn ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '회원가입',
                            style: TextStyle(
                              color: ColorPalette.PRIMARY_COLOR[300]!,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' | ',
                            style: TextStyle(
                              color: ColorPalette.GRAY_COLOR[600]!,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '비밀번호 찾기',
                            style: TextStyle(
                              color: ColorPalette.GRAY_COLOR[600]!,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    opacity: isEmailSignIn && _isLogoVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.decelerate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '이용약관',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: ColorPalette.GRAY_COLOR[400]!,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          ' 및 ',
                          style: TextStyle(
                            color: ColorPalette.GRAY_COLOR[400]!,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '개인정보 취급방침',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: ColorPalette.GRAY_COLOR[400]!,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

class _StartButton extends ConsumerStatefulWidget {
  final FBAuthService auth;
  final bool isEmailSignIn;
  final Function(bool) setEmailSignIn;

  const _StartButton({
    required this.auth,
    required this.isEmailSignIn,
    required this.setEmailSignIn,
  });

  @override
  ConsumerState<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends ConsumerState<_StartButton> {
  Map<String, String?> data = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> getEmailPassword() async {
    data = {
      'email': email,
      'password': password,
    };
  }

  String _validateForm() {
    String result = _validateEmail();
    if (result == '') {
      result = _validatePassword();
    }
    return result;
  }

  String _validateEmail() {
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(email)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return '';
  }

  String _validatePassword() {
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[A-Za-z])(?=.*[\W_])[A-Za-z\d\W_]{8,20}$');
    if (!passwordRegExp.hasMatch(password)) {
      return '비밀번호는 8-20자이며, 특수문자를 포함해야 합니다.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.45,
      child: ElevatedButton(
        // '로그인' 버튼을 누를 때 동작
        onPressed: () async {
          if (widget.isEmailSignIn) {
            FocusScope.of(context).unfocus();
            String validateResult = _validateForm();
            ref
                .read(signInValidateProvider.notifier)
                .update((state) => validateResult);
            if (validateResult.isNotEmpty) return;

            try {
              await getEmailPassword();
              final resp = await DioClient().post(
                  '${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/auth/login', data);
              print('[sign_in_view.dart] data: $data');

              if (resp.statusCode == 200) {
                print('sign_in_view: ${resp.data}');

                setEmailPassword(email, password);

                await storage.write(
                    key: ACCESS_TOKEN_KEY, value: resp.data['accessToken']);
                await storage.write(
                    key: REFRESH_TOKEN_KEY, value: resp.data['refreshToken']);

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MainCalendar(auth: widget.auth)));
              }
            } catch (e) {
              String errorString = '';
              if (e == 401) {
                // 401 Unauthorized: 없는 계정 또는 잘못된 비밀번호
                errorString = '이메일 또는 비밀번호가 일치하지 않습니다.';
              } else if (e == 422) {
                // 422 Unprocessable Entity: 올바르지 않은 형식의 요청
                errorString = '올바른 형식이 아닙니다.';
              } else {
                // 서버 응답 없음 또는 타임아웃
                errorString = '서버와의 응답이 없습니다, 잠시 후 다시 시도해 주세요.';
              }
              ref
                  .read(signInValidateProvider.notifier)
                  .update((state) => errorString);
            }
          }
          // '시작' 버튼을 누를 때 동작
          else {
            CustomModalBottomSheet(
              context: context,
              backgroundColor: ColorPalette.GRAY_COLOR[50]!,
              content: Column(
                children: [
                  Visibility(
                    visible: true,
                    child: Align(
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
                  ),
                  Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final response =
                            await widget.auth.signInWithGoogle(ref);

                        if (response != null) {
                          // && response['statusCode'] == 200) {
                          await storage.write(
                              key: ACCESS_TOKEN_KEY,
                              value: response['accessToken']);
                          await storage.write(
                              key: REFRESH_TOKEN_KEY,
                              value: response['refreshToken']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MainCalendar(auth: widget.auth),
                            ),
                          );
                        } else {
                          print('response: $response');
                          showSnackbar(
                              context, '로그인 중 오류가 발생했습니다, 잠시 후 다시 시도해 주세요.');
                        }
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
                          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
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
                        email = '';
                        password = '';
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
                          backgroundColor: ColorPalette.SECONDARY_COLOR[400]!,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0))),
                    ),
                  ),
                  Spacer(),
                ],
              ),
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
