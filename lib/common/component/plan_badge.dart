import 'package:flutter/material.dart';

import '../const/color.dart';

class PlanBadge extends StatelessWidget {
  final String tier;

  PlanBadge({
    super.key,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1,
    );

    BoxDecoration boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorPalette.GRAY_COLOR[200]!,
          Color(0xFF67696C),
        ],
      ),
    );

    if (tier == 'Pro') {
      boxDecoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorPalette.PRIMARY_COLOR[400]!,
            Color(0xFF001331),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: boxDecoration,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 14,
            child: Text(
              tier,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
