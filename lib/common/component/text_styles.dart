import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../const/color.dart';

class AppTextStyles {
  // 로그인 버튼 아래 옵션 텍스트
  static TextStyle loginOptionTextStyle = TextStyle(
    color: ColorPalette.PRIMARY_COLOR[300]!,
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  static TextStyle policyTextStyle = TextStyle(
    color: ColorPalette.GRAY_COLOR[400]!,
    fontWeight: FontWeight.w500,
    fontSize: 10,
  );

  static TextStyle policyUnderlineTextStyle = TextStyle(
    decoration: TextDecoration.underline,
    color: ColorPalette.GRAY_COLOR[400]!,
    fontWeight: FontWeight.w500,
    fontSize: 10,
  );

  static TextStyle heading1 = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );
}
