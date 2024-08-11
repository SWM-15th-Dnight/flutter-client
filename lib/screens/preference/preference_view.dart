import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PreferenceView extends StatelessWidget {
  const PreferenceView({super.key});

  // TODO. split
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 및 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              signOut();
            },
            child: Text(
              '로그아웃',
            ),
          ),
        ),
      ),
    );
  }
}
