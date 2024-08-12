import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.obscureText = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // 비밀번호 입력할 때
      obscureText: obscureText,
      // 값이 바뀔 때마다 실행되는 callback
      onChanged: onChanged,

      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}
