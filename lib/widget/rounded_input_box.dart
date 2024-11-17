import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/common/const/color.dart';

class RoundedInputBox extends StatelessWidget {
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
  bool showLeadingText;
  String? leadingText;
  double customHeight;
  double? customWidth;
  bool enabled;

  RoundedInputBox({
    super.key,
    this.hintText,
    this.obscureText = false,
    required this.onChanged,
    this.textAlign = TextAlign.start,
    this.scrollPadding,
    this.maxLength = 301,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.suffixIcon,
    required this.onIconPressed,
    this.validator,
    this.showLeadingText = false,
    this.leadingText,
    this.customWidth,
    this.customHeight = 48,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLeadingText && leadingText != null)
          Container(
            width: customWidth ?? MediaQuery.of(context).size.width * 0.8,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 4,
                  color: ColorPalette.GRAY_COLOR[400]!,
                ),
                SizedBox(width: 4),
                Text(
                  leadingText!,
                  style: TextStyle(
                    color: ColorPalette.GRAY_COLOR[400]!,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: showLeadingText ? 4 : 0),
        Container(
          width: customWidth ?? MediaQuery.of(context).size.width * 0.8,
          height: customHeight,
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
            // 직접 입력 자체를 막을 때
            enabled: enabled,
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
              /* give contentPadding to hintText align vertically center */
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              /* set prefix to default IconButton size to hintText align horizontally center */
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
        ),
      ],
    );
  }
}
