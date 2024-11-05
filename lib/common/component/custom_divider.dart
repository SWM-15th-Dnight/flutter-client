import 'package:flutter/material.dart';

import '../const/color.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      height: 1.0,
      color: ColorPalette.GRAY_COLOR[100]!,
    );
  }
}
