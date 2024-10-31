
import 'dart:ui';

import 'color_map.dart';
import 'event.dart';

class Calendar {
  late final int id;
  late final String title;
  late final String timezoneId;
  late final DateTime createdAt;
  late final DateTime updatedAt;
  late final int colorSetId;
  late final String? description;
  late bool isSelected;

  List<Event> eventList = [];

  late Color color;
  late ColorMap colorMap;

  Calendar(input){
    id = input['calendarId'];
    title = input['title'];
    timezoneId = input['timezoneId'];
    createdAt = DateTime.parse(input['createdAt']);
    updatedAt = DateTime.parse(input['updatedAt']);
    colorSetId = input['colorSetId'];
    description = input['description'];
    isSelected = true; // 기본으로 Displayed 됨
  }

  void setColor(){
    color = colorMap.get(colorSetId);
  }

  void addEvent(Event event){
    eventList.add(event);
  }

  void setColorMap(ColorMap input){
    colorMap = input;
  }
}