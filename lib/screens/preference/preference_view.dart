import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PreferenceView extends StatefulWidget {
  final String? photoURL;

  const PreferenceView({
    super.key,
    required this.photoURL,
  });

  @override
  State<PreferenceView> createState() => _PreferenceViewState();
}

class _PreferenceViewState extends State<PreferenceView> {
  // TODO. split
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final double photoLength = MediaQuery.of(context).size.width * 0.4;

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
            child: Image.network(
              widget.photoURL!,
              width: photoLength,
              height: photoLength,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: Text(
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
