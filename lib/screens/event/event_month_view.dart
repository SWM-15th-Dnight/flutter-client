import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../entities/event.dart';

// EventMonthViewCell
// 캘린더의 한 칸을 렌더링하는 함수
Widget EventMonthViewCell(context, constraints, events, day, colorMap){
  double fontSize = calculateFontSize(context);
  double totalHeight = 0;
  int remainingEvents = 0;

  List<Widget> eventWidgets = [];

  if (events != null) {
    for (DisplayEvent event in events) {
      event.setColor(colorMap);

      var textStyle = TextStyle(
        fontSize: fontSize,
        height: 1.4,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.05,
        overflow: TextOverflow.ellipsis,
      );

      var textHeight = calcHeight(constraints, event.summary, textStyle);
      if (totalHeight + textHeight * 2 > constraints.maxHeight) {
        remainingEvents++;
      } else {
        totalHeight += textHeight;
        eventWidgets.add(event.render(textStyle));
      }
    }

    if (remainingEvents > 0) {
      //remainingEvents += 1;
      //displayEvents -= 1;
      eventWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Container(
          color: Color(0xFFAAAAAA).withOpacity(0.3),
          width: double.infinity,
          child: Center(
            child: Text(
              '+${remainingEvents}',
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
          ),
        ),
      ));
    }
  }

  return Column(
    children: eventWidgets,
  );
}

double calculateFontSize(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 360) {
    return 8.0;
  } else if (screenWidth < 720) {
    return 10.0;
  } else {
    return 12.0;
  }
}

double calcHeight(constraints, text, textStyle){
  final textSpan = TextSpan(
    text: text,
    style: textStyle,
  );
  final textPainter = TextPainter(
    text: textSpan,
    maxLines: 1,
    textDirection: ui.TextDirection.ltr,
  );
  textPainter.layout(maxWidth: constraints.maxWidth);
  final textHeight = textPainter.height + (2.0 + 4.0); // Add padding + 2
  return textHeight;
}