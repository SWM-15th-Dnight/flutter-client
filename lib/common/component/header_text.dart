import 'package:flutter/material.dart';

import '../const/color.dart';

class HeaderText extends StatelessWidget {
  final String? text;

  const HeaderText({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 18.0,
        color: ColorPalette.PRIMARY_COLOR[400],
      ),
    );
  }
}
