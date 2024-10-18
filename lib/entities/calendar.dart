
import 'dart:ui';

import 'color_map.dart';

class Calendar {
  late final int id;
  late final String title;
  late final String timezoneId;
  late final DateTime createdAt;
  late final DateTime updatedAt;
  late final int colorSetId;
  late final String? description;

  late Color color;
  late bool isSelected;

  Calendar(input){
    id = input['calendarId'];
    title = input['title'];
    timezoneId = input['timezoneId'];
    createdAt = DateTime.parse(input['createdAt']);
    updatedAt = DateTime.parse(input['updatedAt']);
    colorSetId = input['colorSetId'];
    description = input['description'];

    setColor();
    isSelected = true; // 기본으로 Displayed 됨
  }

  void setColor() async {
    ColorMap colormap = ColorMap();
    color = await colormap.get(colorSetId);
  }

}

