
import 'package:flutter/material.dart';

import '../common/const/color.dart';

void modal(context, title, children){
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
    builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                // TODO. Text 상단 고정하고, bottom overflow시 스크롤되게
                const SizedBox(height: 20.0),
                Text(
                  '${title}',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                    child: ListView(
                      children: children,
                    )),
              ],
            ),
          ),
        ),
      );
    },
  );
}