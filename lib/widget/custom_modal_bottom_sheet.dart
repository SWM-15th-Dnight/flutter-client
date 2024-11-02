import 'package:flutter/material.dart';
import 'package:mobile_client/common/const/color.dart';

Future<void> CustomModalBottomSheet({
  required BuildContext context,
  required Widget content,
  Color? backgroundColor,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.2),
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.25,
          color: backgroundColor ?? ColorPalette.GRAY_COLOR[100]!,
          child: content,
        ),
      );
    },
  );
}
