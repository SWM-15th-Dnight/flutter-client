import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_client/screens/signIn/sign_in_view.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/component/header_text.dart';
import '../../common/const/color.dart';
import '../../entities/user.dart';
import '../root/root_view.dart';

class PreferenceView extends StatefulWidget {
  final FBAuthService auth;
  String? displayName = '익명';

  PreferenceView({
    super.key,
    required this.auth,
  });

  @override
  State<PreferenceView> createState() => _PreferenceViewState();
}

class _PreferenceViewState extends State<PreferenceView> {
  File? image;
  final picker = ImagePicker();
  final TextEditingController displayNameController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadDisplayName();
  }

  Future<void> _pickImage() async {
    print('pick image');
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final fileName = 'profile_image.png';
      final File localImage =
          await File(pickedFile.path).copy('$path/$fileName');

      setState(() {
        image = localImage;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('profile_image_path')) {
        prefs.remove('profile_image_path');
      }
      prefs.setString('profile_image_path', localImage.path);

      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null) {
      setState(() {
        image = File(imagePath);
      });
    }
  }

  Future<void> _loadDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    widget.displayName = prefs.getString('display_name') ?? '익명';
    setState(() {
      displayNameController.text = widget.displayName!;
    });
  }

  Future<void> _updateDisplayName() async {
    print('onTap: update display name');
    if (isEditing) {
      final newName = displayNameController.text;
      if (newName.isNotEmpty) {
        widget.auth.getCurrentUser()?.updateDisplayName(newName);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('display_name', newName);
        setState(() {
          widget.displayName = newName;
          print('수정된 이름: ${widget.displayName}');
          isEditing = false;
        });
      }
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: AppBar(
            centerTitle: true,
            title: HeaderText(text: '프로필 및 설정'),
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
          GestureDetector(
            onTap: _pickImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(161616.0),
              child: image != null
                  ? Image.file(
                      image!,
                      width: photoLength,
                      height: photoLength,
                      fit: BoxFit.cover,
                    )
                  : widget.auth.getCurrentUser()?.photoURL != null
                      ? Image.network(
                          widget.auth.getCurrentUser()!.photoURL!,
                          width: photoLength,
                          height: photoLength,
                          fit: BoxFit.cover,
                        )
                      : Stack(
                          children: [
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
                          ],
                        ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isEditing
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextField(
                        controller: displayNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '보여질 이름을 알려주세요!',
                        ),
                      ),
                    )
                  : Text(
                      widget.displayName!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _updateDisplayName,
                child: Icon(
                  isEditing ? Icons.check : Icons.edit_note,
                  size: 24,
                  //color: Colors.transparent,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                '로그아웃',
                style: TextStyle(
                  color: ColorPalette.GRAY_COLOR[50]!,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
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
