import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.obscureText = false,
    required this.onChanged,
    this.textAlign = TextAlign.start,
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
      ),
    );
  }
}
