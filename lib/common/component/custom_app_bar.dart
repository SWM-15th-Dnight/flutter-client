import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../const/color.dart';

/* Icons. */
// arrow_back
// more_horiz          // three dots
// menu                // hamburger
// save
// settings
// close                // x
// add                  // +
// chevron_left, Icons.chevron_right   // '<', '>'
// check

class CustomAppBar extends StatelessWidget {
  final bool isVisible;
  final Widget? leftWidget;
  final dynamic centerContent; // String or DateTime type
  final Widget? rightWidget;
  final double gutterSize;

  CustomAppBar({
    super.key,
    this.isVisible = true,
    this.leftWidget,
    this.centerContent,
    this.rightWidget,
    this.gutterSize = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    String centerText = '';
    if (centerContent is String) {
      centerText = centerContent;
    } else if (centerContent is DateTime) {
      centerText = DateFormat.MMMM('ko_KR').format(centerContent);
      if (centerContent.year != DateTime.now().year) {
        centerText = DateFormat.yMMMM('ko_KR').format(centerContent);
      }
    } else {
      centerText = '';
    }

    return Visibility(
      visible: isVisible,
      child: PreferredSize(
        // set the height of the app bar
        preferredSize: Size.fromHeight(52),
        child: Container(
          color: Colors.transparent,
          // set the height of the app bar
          height: 52,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gutterSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leftWidget != null ? leftWidget! : SizedBox(width: 48.0),
                Text(
                  centerText ?? '',
                  style: TextStyle(
                    color: ColorPalette.PRIMARY_COLOR[400]!,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                rightWidget != null ? rightWidget! : SizedBox(width: 48.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
