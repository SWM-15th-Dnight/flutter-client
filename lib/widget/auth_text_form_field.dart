import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthTextFormField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  double? scrollPadding;
  int maxLength;
  TextEditingController? controller;
  FocusNode? focusNode;
  bool autofocus;
  IconData? suffixIcon;
  VoidCallback onIconPressed;
  String? Function(String?)? validator;

  AuthTextFormField({
    super.key,
    this.hintText,
    this.obscureText = false,
    required this.onChanged,
    this.textAlign = TextAlign.start,
    this.scrollPadding,
    this.maxLength = 100,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.suffixIcon,
    required this.onIconPressed,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      autofocus: autofocus,
      // 비밀번호 입력할 때
      obscureText: obscureText,
      // 값이 바뀔 때마다 실행되는 callback
      onChanged: onChanged,
      textAlign: textAlign,
      maxLength: maxLength,

      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            //color: Colors.grey,
          ),
          counterText: '',
          suffixIcon: IconButton(
            // resize

            icon: Icon(
              suffixIcon,
              size: 20,
            ),
            onPressed: () {
              onIconPressed();
            },
          )),
      scrollPadding: EdgeInsets.only(bottom: scrollPadding ?? 0),
      validator: validator,
    );
  }
}
