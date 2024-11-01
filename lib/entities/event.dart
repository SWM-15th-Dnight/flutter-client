
import 'package:intl/intl.dart';

import 'calendar.dart';

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
  late int colorSetId;

  String? description;
  String? location;

  Event({
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

  DisplayEvent.from(Event event, DateTime day)
      : super(
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

    if(start == end) {
      range = EventType.day;
    }
    else if(start == day){
      range = EventType.start;
    }
    else if(end == day){
      range = EventType.end;
    }
    else{
      range = EventType.during;
    }

    date = day;
  }
}

DateTime onlyDate(DateTime T){
  DateTime ret = DateTime.utc(T.year, T.month, T.day);
  return ret;
}