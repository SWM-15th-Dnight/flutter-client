import 'package:flutter/material.dart';

class AuthTextFormField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  double? scrollPadding;

  AuthTextFormField({
    super.key,
    this.hintText,
    this.obscureText = false,
    required this.onChanged,
    this.textAlign = TextAlign.start,
    this.scrollPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // 비밀번호 입력할 때
      obscureText: obscureText,
      // 값이 바뀔 때마다 실행되는 callback
      onChanged: onChanged,
      textAlign: textAlign,

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          //color: Colors.grey,
        ),
      ),
      scrollPadding: EdgeInsets.only(bottom: scrollPadding ?? 0),
    );
  }
}
