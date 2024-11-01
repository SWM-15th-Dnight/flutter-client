import 'package:flutter/material.dart';
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
  final String? centerText;
  final Widget? rightWidget;
  final double gutterSize;

  CustomAppBar({
    super.key,
    this.isVisible = true,
    this.leftWidget,
    this.centerText,
    this.rightWidget,
    this.gutterSize = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Visibility(
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
      ),
    );
  }
}
