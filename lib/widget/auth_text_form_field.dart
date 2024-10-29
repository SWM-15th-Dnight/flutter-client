import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/common/const/color.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.GRAY_COLOR[50]!,
        borderRadius: BorderRadius.circular(45),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
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
            color: ColorPalette.GRAY_COLOR[400]!,
            fontSize: 14,
          ),
          counterText: '',
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          /* set prefix to default IconButton size to hintText align center */
          prefix: SizedBox(width: 48),
          suffixIcon: IconButton(
            // resize
            icon: Icon(
              suffixIcon,
              color: ColorPalette.GRAY_COLOR[400]!,
              size: 18,
            ),
            onPressed: () {
              onIconPressed();
            },
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),

        scrollPadding: EdgeInsets.only(bottom: scrollPadding ?? 0),
        validator: validator,
      ),
    );
  }
}
