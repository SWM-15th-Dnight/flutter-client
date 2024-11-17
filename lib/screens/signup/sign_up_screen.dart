import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/component/custom_app_bar.dart';
import 'package:mobile_client/common/component/snackbar_helper.dart';
import 'package:mobile_client/common/component/text_styles.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/common/layout/default_layout.dart';
import 'package:mobile_client/services/dio_client.dart';
import 'package:mobile_client/widget/rounded_input_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/component/custom_divider.dart';
import '../../widget/custom_modal_bottom_sheet.dart';

String email = '';
String password = '';
String passwordConfirm = '';
String userName = '익명';
DateTime birthday = DateTime.now();
String selectedGender = '선택 안함';
bool isValidated = false;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;

  // TextFormField
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordConfirmFocusNode = FocusNode();
  var adder = 100.0;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_validateForm);
    _passwordFocusNode.addListener(_validateForm);
    _passwordConfirmFocusNode.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (!_emailFocusNode.hasFocus &&
        !_passwordFocusNode.hasFocus &&
        !_passwordConfirmFocusNode.hasFocus) {
      setState(() {
        isValidated = _isValidEmail(email) &&
            _isValidPassword(password) &&
            password == passwordConfirm;
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*[\W_])[A-Za-z\d\W_]{8,20}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInSet = MediaQuery.of(context).viewInsets.bottom;

    // TODO. 배경색
    return DefaultLayout(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AppBar
              CustomAppBar(
                isVisible: true,
                leftWidget: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerContent: '회원가입',
              ),
              Text(
                '가입을 위해 정보를 입력해주세요.',
                style: AppTextStyles.heading1,
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RoundedInputBox(
                      showLeadingText: true,
                      leadingText: '이메일',
                      textAlign: TextAlign.center,
                      hintText: '이메일',
                      maxLength: 40,
                      focusNode: _emailFocusNode,
                      suffixIcon: Icons.clear,
                      onIconPressed: () {
                        setState(() {
                          _emailController.clear();
                          email = '';
                        });
                      },
                      onChanged: (String value) async {
                        setState(() {
                          email = value;
                        });
                      },
                      scrollPadding: bottomInSet / 5,
                    ),
                    SizedBox(height: 20),
                    RoundedInputBox(
                      showLeadingText: true,
                      leadingText: '비밀번호',
                      obscureText: !_isPasswordVisible,
                      textAlign: TextAlign.center,
                      hintText: '비밀번호',
                      maxLength: 20,
                      focusNode: _passwordFocusNode,
                      suffixIcon: _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onIconPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onChanged: (String value) async {
                        password = value;
                      },
                      scrollPadding: bottomInSet / 5,
                    ),
                    SizedBox(height: 20),
                    RoundedInputBox(
                      textAlign: TextAlign.center,
                      hintText: '비밀번호 확인',
                      obscureText: !_isPasswordVisible,
                      maxLength: 20,
                      focusNode: _passwordConfirmFocusNode,
                      suffixIcon: _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onIconPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onChanged: (String value) async {
                        passwordConfirm = value;
                      },
                      scrollPadding: bottomInSet / 2,
                    ),
                    SizedBox(height: 60),
                    RoundedInputBox(
                      showLeadingText: true,
                      leadingText: '이름/별명',
                      textAlign: TextAlign.center,
                      hintText: userName,
                      maxLength: 20,
                      onIconPressed: () {},
                      onChanged: (String value) async {
                        setState(() {
                          userName = value;
                        });
                      },
                      scrollPadding: bottomInSet / 3,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        CustomModalBottomSheet(
                          context: context,
                          content: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            // TODO. Order: AM/PM, hour, minute
                            //dateOrder: DatePickerDateTimeOrder.date_dayPeriod_time,
                            // set initialDateTime adjust to minuteInterval
                            initialDateTime: birthday,
                            minimumDate: DateTime(1900, 1, 1),
                            maximumDate: DateTime.now(),
                            onDateTimeChanged: (DateTime value) {
                              setState(() {
                                birthday = value;
                              });
                            },
                          ),
                        );
                      },
                      child: RoundedInputBox(
                        showLeadingText: true,
                        leadingText: '생일',
                        textAlign: TextAlign.center,
                        enabled: false,
                        hintText: DateFormat('yyyy. M. d.').format(birthday),
                        maxLength: 20,
                        onIconPressed: () {},
                        onChanged: (String value) {},
                        scrollPadding: bottomInSet,
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        var contextWidth =
                            MediaQuery.of(context).size.width * 0.90;
                        String? gender = await CustomModalBottomSheet(
                          context: context,
                          content:
                              StatefulBuilder(builder: (context, setState) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Column(
                                    children: [
                                      _buildGenderOption(
                                          contextWidth, '남성', setState),
                                      CustomDivider(),
                                      _buildGenderOption(
                                          contextWidth, '여성', setState),
                                      CustomDivider(),
                                      _buildGenderOption(
                                          contextWidth, '선택 안함', setState),
                                      CustomDivider(),
                                      // TODO. 텍스트 입력 및 키보드 스크롤
                                      _buildGenderOption(
                                          contextWidth, '사용자화', setState),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        );

                        if (gender != null) {
                          setState(() {
                            selectedGender = gender;
                          });
                        }
                      },
                      child: RoundedInputBox(
                        showLeadingText: true,
                        leadingText: '성별',
                        textAlign: TextAlign.center,
                        enabled: false,
                        hintText: selectedGender,
                        maxLength: 20,
                        onIconPressed: () {},
                        onChanged: (String value) {},
                        scrollPadding: bottomInSet + adder,
                      ),
                    ),
                    SizedBox(height: 60),
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!isValidated) {
                            return;
                          }
                          // TODO. 현재 백엔드에서 [female, male]만 지원하는 상태
                          // TODO. 회원가입 로직
                          Map<String, String?> data = {
                            'email': email,
                            'password': password,
                            'userName': userName,
                            'gender':
                                selectedGender == '여성' ? 'female' : 'male',
                            'phoneNumber':
                                DateFormat('yyyy. M. d.').format(birthday),
                          };
                          print(data);

                          try {
                            final response = await DioClient().post(
                                '${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/auth/',
                                data);
                            print(response.data);
                            print(response.statusCode);
                            if (response.statusCode == 201) {
                              showSnackbar(context,
                                  '${response.data['userName']}님, 회원가입이 완료되었습니다!');
                              // 가입 시 userName 저장
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('userName', userName);
                              Navigator.pop(context);
                            }
                          } on DioError catch (e) {
                            if (e.response?.statusCode == 422) {
                              showSnackbar(context, '이미 가입된 이메일 입니다.');
                            } else {
                              showSnackbar(
                                  context, '응답 코드: ${e.response?.statusCode}');
                            }
                          } catch (e) {
                            print(e);
                            showSnackbar(context, '잠시 후 다시 시도해주세요.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValidated
                              ? ColorPalette.PRIMARY_COLOR[400]!
                              : ColorPalette.PRIMARY_COLOR[200]!,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          '가입하기',
                          style: TextStyle(
                            color: ColorPalette.GRAY_COLOR[50]!,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: bottomInSet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(
      double contextWidth, String gender, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
        Navigator.pop(context, gender);
      },
      child: Container(
        color: ColorPalette.GRAY_COLOR[50]!,
        child: SizedBox(
          width: contextWidth,
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  gender,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (selectedGender == gender)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.check,
                    color: ColorPalette.PRIMARY_COLOR[400]!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
