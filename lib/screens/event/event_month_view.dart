import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// EventMonthViewCell
// 캘린더의 한 칸을 렌더링하는 함수
Widget EventMonthViewCell(context, constraints, events, day, colorMap){
  double fontSize = calculateFontSize(context);
  double totalHeight = 0;
  int remainingEvents = 0;

  List<Widget> eventWidgets = [];

  if (events?[DateFormat('yyyy-MM-dd').format(day)] != null) {
    for (var event in events![DateFormat('yyyy-MM-dd').format(day)]!) {
      var eventView = EventMonthViewElem(event, fontSize, colorMap);

      var textHeight = eventView.calcHeight(constraints);
      if (totalHeight + textHeight * 2 > constraints.maxHeight) {
        remainingEvents++;
      } else {
        totalHeight += textHeight;
        eventWidgets.add(eventView.render());
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

// EventMonthViewElem
// 캘린더의 일정 하나를 저장하고 렌더링하는 클래스
class EventMonthViewElem{
  late final startAtTime;
  late final endAtTime;
  late final isAllDay;
  late final text;
  late final textStyle;
  late final eventColor;

  EventMonthViewElem(var event, fontSize, colorMap){
    startAtTime = DateFormat('HH:mm:ss').format(DateTime.parse(event['startAt']));
    endAtTime = DateFormat('HH:mm:ss').format(DateTime.parse(event['endAt']));
    isAllDay = (startAtTime == '00:00:00') &&
        (endAtTime == '00:00:00')
        ? false
        : true;
    text = event['summary'];
    textStyle = TextStyle(
      fontSize: fontSize,
      height: 1.4,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.05,
      overflow: TextOverflow.ellipsis,
    );
    eventColor = colorMap.get(event['colorSetId']);
  }

  double calcHeight(constraints){
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
    final textHeight =
        textPainter.height + (2.0 + 4.0); // Add padding + 2
    return textHeight;
  }

  Widget render(){
    return (ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 1.0),
          color: isAllDay
              ? eventColor
              .withOpacity(0.15)
              : eventColor,
          width: double.infinity,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ));
  }
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