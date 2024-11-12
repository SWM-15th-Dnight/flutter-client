import 'dart:math';

import 'package:intl/intl.dart';

import 'event.dart';
import 'calendar.dart';

class EventList{
  static void Add(Map<int, Calendar> calendarMap, {Event? event, Map<String, dynamic>? input}){
    if(event != null){
      calendarMap[event.calendarId]?.eventList.add(event);
    }
    if(input != null){
      Event event = Event.parse(input);
      calendarMap[event.calendarId]?.eventList.add(event);
    }
  }

  static void Delete(Map<int, Calendar> calendarMap, [int? eventId, Event? event]){
    if(eventId != null){
      for(Calendar cal in calendarMap.values){
        cal.eventList.removeWhere((elem) => elem.eventId == eventId );
      }
    }
    if(event != null){
      for(Calendar cal in calendarMap.values){
        cal.eventList.removeWhere((elem) => elem.eventId == event.eventId );
      }
    }
  }

  static int getIdx(Map<int, DisplayEvent>? cur){
    if(cur == null) return 0;
    int cnt = 0;
    while(cur.containsKey(cnt)){
      cnt++;
    }
    return cnt;
  }

  static List<DisplayEvent> getList(Map<int,DisplayEvent> cur){
    List<DisplayEvent> ret = [];

    int idx = cur.keys.reduce(max);
    print("lastidx ${idx}");
    for(var i=0; i<=idx; i++){
      if(cur.containsKey(i)){
        ret.add(cur[i]!);
      }
      else{
        ret.add(DisplayEvent());
      }
    }

    return ret;
  }

  static Map<DateTime, List<DisplayEvent>> AsDisplay(Map<int, Calendar> calendarMap){
    List<Event> dayList = [];
    List<Event> rangeList = [];

    Map<DateTime, Map<int, DisplayEvent>> cur = {};
    Map<DateTime, List<DisplayEvent>> ret = {};

    for(Calendar cal in calendarMap.values){
      if(cal.isSelected == false) continue;

      for(Event event in cal.eventList){
        DateTime start = onlyDate(event.startAt);
        DateTime end = onlyDate(event.endAt);

        if(start == end) dayList.add(event);
        else rangeList.add(event);
      }
    }

    print("daylist ${dayList.length}, rangelist ${rangeList.length}");

    for(Event event in rangeList){
      DateTime start = onlyDate(event.startAt);
      DateTime end = onlyDate(event.endAt);
      DateTime curr = onlyDate(event.startAt);

      int idx = getIdx(cur[start]);

      while(curr.compareTo(end) != 1){
        DisplayEvent curEvent = DisplayEvent.from(event,curr);

        if(cur[curr] == null) cur[curr] = {};
        cur[curr]![idx] = curEvent;

        curr = curr.add(Duration(days: 1));
      }
    }

    for(Event event in dayList){
      DateTime curr = onlyDate(event.startAt);
      int idx = getIdx(cur[curr]);

      DisplayEvent curEvent = DisplayEvent.from(event, curr);

      if(cur[curr] == null) cur[curr] = {};
      cur[curr]![idx] = curEvent;
    }

    for(var key in cur.keys){
      ret[key] = getList(cur[key]!);
    }

    return ret;
  }
}