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

  static Map<DateTime, List<DisplayEvent>> AsDisplay(Map<int, Calendar> calendarMap){
    List<DisplayEvent> list = [];
    Map<DateTime, List<DisplayEvent>> ret = {};

    for(Calendar cal in calendarMap.values){
      if(cal.isSelected == false) continue;

      for(Event event in cal.eventList){
        DateTime curr = onlyDate(event.startAt);
        DateTime end = onlyDate(event.endAt);
        while(curr.compareTo(end) != 1){
          list.add(DisplayEvent.from(event,curr));
          curr = curr.add(Duration(days: 1));
        }
      }
    }

    for(DisplayEvent event in list){
      if (ret.containsKey(event.date)) {
        ret[event.date]!.add(event);
      } else {
        ret[event.date] = [event];
      }
    }
    return ret;
  }
}