
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';
import 'color_map.dart';

enum EventType { day, start, during, end }

class Event { // Event = 서버와 통신하는 값을 적재해두는 인스턴스 클래스.
  late int eventId;
  late String summary;
  late DateTime startAt;
  late DateTime endAt;
  late String? repeatRule;
  late int priority;
  late bool isAllDay;
  late int calendarId;
  late int? colorSetId;

  String? description;
  String? location;

  Event();

  Event.set({
    required this.eventId,
    required this.summary,
    required this.startAt,
    required this.endAt,
    this.repeatRule,
    required this.priority,
    required this.isAllDay,
    required this.calendarId,
    required this.colorSetId,
    this.description,
    this.location,
  });

  Event.parse(input){
    eventId = input['eventId'];
    summary = input['summary'];
    startAt = DateTime.parse(input['startAt']);
    endAt = DateTime.parse(input['endAt']);
    repeatRule = input['repeatRule'];
    priority = input['priority'];
    isAllDay = (input['isAllday'] == 1 ? true : false);
    calendarId = input['calendarId'];
    colorSetId = input['colorSetId'];
  }
}

class DisplayEvent extends Event{ // DisplayEvent = 화면에 출력되는 값들을 실제 담고 있는 클래스.
  late EventType range;
  late DateTime date;
  late Color color;
  late bool isEmpty = false;
  late int idx;
  late double displayHeight;

  DisplayEvent() : super(){
    isEmpty = true;
    summary = "";
    colorSetId = 1;
  }

  DisplayEvent.from(Event event, DateTime day)
      : super.set(
    eventId: event.eventId,
    summary: event.summary,
    startAt: event.startAt,
    endAt: event.endAt,
    repeatRule: event.repeatRule,
    priority: event.priority,
    isAllDay: event.isAllDay,
    calendarId: event.calendarId,
    colorSetId: event.colorSetId,
    description: event.description,
    location: event.location,
  ){
    DateTime start = onlyDate(event.startAt);
    DateTime end = onlyDate(event.endAt);

    if(start == end) range = EventType.day;
    else if(start == day) range = EventType.start;
    else if(end == day) range = EventType.end;
    else range = EventType.during;

    if(start != day){
      summary = "";
    }
    date = day;
  }

  setColor(ColorMap colorMap){
    color = colorMap.get(colorSetId ?? 1);
  }

  setIdx(int val){
    idx = val;
  }

  setHeight(constraints, Text text, TextStyle textStyle){

  }

  Widget render(TextStyle textStyle){
    Color calcColor(){
      if(isEmpty) return Colors.transparent;
      if(range != EventType.day) return color.withOpacity(0.5);
      return color.withOpacity(0.25);
    }

    BorderRadius calcRadius(){
      if(range == EventType.start) return BorderRadius.only(topLeft: Radius.circular(4.0),bottomLeft: Radius.circular(4.0));
      if(range == EventType.end) return BorderRadius.only(topRight: Radius.circular(4.0),bottomRight: Radius.circular(4.0));
      if(range == EventType.during) return BorderRadius.circular(0.0);
      return BorderRadius.circular(4.0);
    }

    EdgeInsets calcPadding(){
      if(range == EventType.start) return EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0);
      if(range == EventType.end) return EdgeInsets.only(right: 2.0, top: 2.0, bottom: 2.0);
      if(range == EventType.during) return EdgeInsets.symmetric(vertical: 2.0);
      return EdgeInsets.all(2.0);
    }

    if(isEmpty){
      return (ClipRRect(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Container(
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                summary,
                style: textStyle,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ));
    }

    return (Padding(
        padding: calcPadding(),
        child: ClipRRect(
          borderRadius: calcRadius(),
          child: Container(
            color: calcColor(),
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                summary,
                style: textStyle,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
          ),
        )
    ));
  }
}

DateTime onlyDate(DateTime T){
  DateTime ret = DateTime.utc(T.year, T.month, T.day);
  return ret;
}