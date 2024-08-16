import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_client/screens/signIn/sign_in_view.dart';
import 'package:mobile_client/services/auth_service.dart';

import '../../entities/user.dart';
import '../root/root_view.dart';

class PreferenceView extends StatefulWidget {
  final FBAuthService auth;

  PreferenceView({
    super.key,
    required this.auth,
  });

  @override
  State<PreferenceView> createState() => _PreferenceViewState();
}

class _PreferenceViewState extends State<PreferenceView> {
  void _showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text('로그아웃'),
      content: Text('로그아웃 하시면 Calinify의 일정 알림을 받으실 수 없습니다.'),
      actions: <Widget>[
        CancelButton(),
        AcceptButton(
          text: '로그아웃',
          onPressed: widget.auth.signOut(),
          navigator: RootView(auth: widget.auth),
        )
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double photoLength = MediaQuery.of(context).size.width * 0.4;
    // TODO. use shared preference before using local DB
    final String displayName =
        widget.auth.getCurrentUser()?.displayName ?? '익명';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: AppBar(
            centerTitle: true,
            title: Text('프로필 및 설정',
                style: TextStyle(
                  fontSize: 22,
                )),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 32,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(161616.0),
            child: widget.auth.getCurrentUser()?.photoURL != null
                ? Image.network(
                    widget.auth.getCurrentUser()!.photoURL!,
                    width: photoLength,
                    height: photoLength,
                    fit: BoxFit.cover,
                  )
                : Stack(children: [
                    Container(
                      width: photoLength,
                      height: photoLength,
                      color: Colors.grey,
                    ),
                    Image.asset(
                      'asset/img/user/default_account_profile.png',
                      width: photoLength,
                      height: photoLength,
                      fit: BoxFit.cover,
                      color: Colors.black,
                    ),
                  ]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.edit_note,
                  size: 24,
                  color: Colors.transparent,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.edit_note,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _showAlertDialog(context);
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        '취소',
      ),
    );
  }
}

class AcceptButton extends StatelessWidget {
  final String text;
  final Future<void> onPressed;
  final Widget navigator;

  const AcceptButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.navigator,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => navigator),
        );
        //await onPressed;
      },
      child: Text(
        text,
      ),
    );
  }
}
