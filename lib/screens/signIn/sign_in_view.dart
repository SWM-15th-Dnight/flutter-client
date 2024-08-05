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
    // print('< LoginScreen >');

    return Material(
      child: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                //color: Colors.yellow,
                height: MediaQuery.of(context).size.height * 0.50,
                alignment: Alignment.center,
                child: const Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Logo(),
                    _Title(),
                    _StartButton(),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

/*
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

    if (FirebaseAuth.instance.currentUser == null) {
      //print('User is currently signed out!');
      page = HomePage();
    } else {
      //print('User is signed in!');
      page = MainScreen();
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
*/

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
      //width: 300,
      //height: 270,
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
    // var appState = context.watch<AppState>();
    var viewModel = Provider.of<SignInViewModel>(context);

    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
                height: 200,
                color: BG_COLOR,
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () async {
                        viewModel.signInWithGoogle();
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        'assets/images/google_logo.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'Google',
                              style: TextStyle(
                                fontFamily: 'Rockwell',
                                fontWeight: FontWeight.normal,
                              )),
                          TextSpan(
                            text: '로 계속하기',
                          )
                        ]),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        viewModel.signInWithMicrosoft();
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        'assets/images/microsoft_logo.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Microsoft로 계속하기'),
                    ),
                  ],
                )));
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
        // backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
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
    );
  }
}
