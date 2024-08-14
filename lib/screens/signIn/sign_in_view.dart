import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.50,
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    _Logo(),
                    const SizedBox(height: 20),
                    _Title(),
                    const SizedBox(height: 20),
                    _StartButton(),
                  ],
                ),
              ),
            )),
      ),
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

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<SignInViewModel>(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: ElevatedButton(
        onPressed: () {
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
                            viewModel.signInWithGoogle();
                            Navigator.pop(context);
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
                            viewModel.signInWithMicrosoft();
                            Navigator.pop(context);
                          },
                          icon: SvgPicture.asset(
                            'asset/img/logo/microsoft_logo.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: const Text(
                            'Microsoft로 계속하기',
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
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          '시작',
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
