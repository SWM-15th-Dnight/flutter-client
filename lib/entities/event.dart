
import 'package:intl/intl.dart';

class Event {
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

class EventList{
  static Map<String, List<Event>> AsMap(List<Event> li){
    Map<String, List<Event>> ret = {};
    for(Event event in li){
      String key = DateFormat('yyyy-MM-dd').format(event.startAt);
      if (ret.containsKey(key)) {
        ret[key]!.add(event);
      } else {
        ret[key] = [event];
      }
    }
    return ret;
  }
}