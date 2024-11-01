import 'package:intl/intl.dart';

import 'event.dart';
import 'calendar.dart';

class EventList{
  static void Add(Map<int, Calendar> calendarMap, [Event? event, dynamic input]){
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

  static List<Event> Make(Map<int, Calendar> calendarMap){
    List<Event> eventList = [];
    for(var cal in calendarMap.values){
      if(cal.isSelected == true){
        eventList.addAll(cal.eventList);
      }
    }
    return eventList;
  }

  static Map<String, List<Event>> AsMap(Map<int, Calendar> calendarMap){
    Map<String, List<Event>> ret = {};
    for(Calendar cal in calendarMap.values){
      if(cal.isSelected == false) continue;
      for(Event event in cal.eventList){
        String key = DateFormat('yyyy-MM-dd').format(event.startAt);
        if (ret.containsKey(key)) {
          ret[key]!.add(event);
        } else {
          ret[key] = [event];
        }
      }
    }
    return ret;
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
          print(curr);
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