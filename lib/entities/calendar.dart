
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

  late final Color displayColor;

  Calendar(input){
    id = input['calendarId'];
    title = input['title'];
    timezoneId = input['timezoneId'];
    createdAt = DateTime.parse(input['createdAt']);
    updatedAt = DateTime.parse(input['updatedAt']);
    colorSetId = input['colorSetId'];
    description = input['description'];

    ColorMap colormap = ColorMap();
    displayColor = colormap.get(colorSetId);
  }
}