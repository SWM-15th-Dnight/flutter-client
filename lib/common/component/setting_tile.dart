import 'package:flutter/material.dart';

import '../const/color.dart';

class SettingTile extends StatelessWidget {
  final String titleText;
  String? trailingText;
  Function()? onTapEvent;

  SettingTile({
    super.key,
    required this.titleText,
    this.trailingText,
    this.onTapEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorPalette.GRAY_COLOR[50]!,
      child: ListTile(
        title: Text(
          titleText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailingText ?? '',
              style: TextStyle(
                color: ColorPalette.GRAY_COLOR[400]!,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ColorPalette.GRAY_COLOR[400]!,
            ),
          ],
        ),
        onTap: onTapEvent,
      ),
    );
  }
}
