import 'dart:convert';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_client/screens/root/root_view.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/widget/custom_sidebar_modal.dart';
import '../../services/auth_service.dart';
import '../../widget/custom_speed_dial.dart';
import '../preference/preference_view.dart';

class MainCalendar extends StatefulWidget {
  final FBAuthService auth;

  MainCalendar({
    super.key,
    required this.auth,
  });

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  User? user;
  final dio = Dio();
  Map<String, dynamic>? _calendarData;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // TODO.
  final String timeMin = '2023-01-01T00:00:00Z';
  final String timeMax = '2024-12-31T23:59:59Z';

  @override
  void initState() {
    super.initState();
    user = widget.auth.getCurrentUser();

    //fetchCalendarData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void addEventToMap(Map<String, List<Map<String, dynamic>>> events,
      String dateKey, Map<String, dynamic> newEvent) {
    if (events.containsKey(dateKey)) {
      // If the date key exists, append the new event to the list
      events[dateKey]!.add(newEvent);
    } else {
      // If the date key does not exist, create a new list with the event
      events[dateKey] = [newEvent];
    }
  }

  Future<void> fetchCalendarData() async {
    var headers = await widget.auth.getAuthHeaders();
    try {
      final resp = await dio.get(
          'https://www.googleapis.com/calendar/v3/calendars/primary/events',
          queryParameters: {
            'timeMin': timeMin,
            'timeMax': timeMax,
          },
          options: Options(headers: headers));
      print('status code: ${resp.statusCode}');
      // for (var event in resp.data['items']) {
      //   print(event);
      // }

      // TODO. holiday
      // ISSUE. Uri.encodeFull(uri) doesn't work
      var holiday = 'ko.south_korea%23holiday%40group.v.calendar.google.com';
      var uri =
          'https://www.googleapis.com/calendar/v3/calendars/${holiday}/events';

      final resp2 = await dio.get(uri,
          queryParameters: {
            'timeMin': timeMin,
            'timeMax': timeMax,
            'key': dotenv.env['GOOGLE_CALENDAR_API_KEY'],
          },
          options: Options(headers: headers));
      print('status code2: ${resp2.statusCode}');
      print(resp2.data);

      final resp0 = await dio.get(
          'https://www.googleapis.com/calendar/v3/users/me/calendarList',
          options: Options(headers: headers));
      print('status code0: ${resp0.statusCode}');
      print(resp0.data);

      // 9fe1e7, 000000
      // 16a765, 000000

      setState(() {
        _calendarData = resp.data;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  /*
  Future<Map<String, dynamic>> fetchCalendarData() async {
    http.Client client = http.Client();
    var headers = await widget.fbUser.authHeaders;
    var resp = await client.get(
        Uri.parse(
          "https://www.googleapis.com/calendar/v3/calendars/primary/events",
        ),
        headers: headers);

    if (resp.statusCode == 403) {
      headers = await widget.fbUser.getAuthHeader();
      resp = await client.get(
          Uri.parse(
            "https://www.googleapis.com/calendar/v3/calendars/primary/events",
          ),
          headers: headers);
    }

    print('headers: $headers');
    print('status code: ${resp.statusCode}');
    print('body: ${resp.body}');
    print(
        '${widget.fbUser.email} ${widget.fbUser.displayName} ${widget.fbUser.uid}');

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
  */

  @override
  Widget build(BuildContext context) {
    /*
    if (events[DateFormat('yyyy-MM-dd').format(day)] !=
        null) {
      eventTitle =
          '${events[DateFormat('yyyy-MM-dd').format(day)]!.length}';
    }
    if (cals?['item']['start'])
    */

    /*
    if (_calendarData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    */

    // TODO. Range Event
    List<dynamic> events = []; //_calendarData?['items'];
    Map<String, List<Map<String, dynamic>>> dateEvents = {};

    print('events.length: ${events.length}');
    if (events.length != 0) {
      for (var i = 0; i < events.length; i++) {
        String startDateTime =
            events[i]['start']['dateTime'] ?? events[i]['start']['date'];
        startDateTime =
            DateFormat('yyyy-MM-dd').format(DateTime.parse(startDateTime));
        //print(startDateTime);

        addEventToMap(dateEvents, startDateTime, events[i]);
      }
    }

    return Scaffold(
      floatingActionButton: const Align(
        alignment: Alignment(0.96, 0.99),
        child: CustomSpeedDial(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              focusedDay: _focusedDay,
              onSidebarButtonPressed: () {
                CustomSidebarModal().sidebarModal(context);
              },
              onProfileButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PreferenceView(auth: widget.auth),
                  ),
                );
              },
              photoURL: user?.photoURL,
            ),
            Flexible(
              flex: 10,
              child: TableCalendar(
                locale: 'ko_KR',
                // notice. TableCalendar should be in Container
                shouldFillViewport: true,
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(1800, 1, 1),
                lastDay: DateTime.utc(3000, 1, 1),
                onPageChanged: _onPageChanged,
                daysOfWeekHeight: 30.0,
                // TODO. WeekDays' Style
                daysOfWeekStyle: DaysOfWeekStyle(),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.black),
                  //weekendTextStyle: TextStyle(color: Colors.red),
                  cellMargin: EdgeInsets.symmetric(vertical: 12.0),
                ),
                headerVisible: false,
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  // delete calendar view mode button
                  // ex. 2 Weeks
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    color: ColorPalette.PRIMARY_COLOR[400],
                  ),
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                ),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return CustomCalendarBuilder(
                      day: day,
                      focusedDay: focusedDay,
                      events: dateEvents,
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return CustomCalendarBuilder(
                      day: day,
                      focusedDay: focusedDay,
                      dayColor: Color(0XFFAAAAAA),
                      events: dateEvents,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return CustomCalendarBuilder(
                      day: day,
                      focusedDay: focusedDay,
                      events: dateEvents,
                      /* debug - border
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColorPalette.PRIMARY_COLOR[400]!,
                                width: 0.8),
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          */
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return CustomCalendarBuilder(
                      day: day,
                      focusedDay: focusedDay,
                      events: dateEvents,
                      isSelected:
                          ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.05),
                      /*
                      decoration: BoxDecoration(
                        color:
                            ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.05),
                        // border: Border.all(
                        //     color: ColorPalette.SECONDARY_COLOR[400]!
                        //         .withOpacity(0.0),
                        //     width: 0.8),
                        // borderRadius: BorderRadius.circular(3.0),
                      ),
                      */

                      //dayFontWeight: FontWeight.w500,
                    );
                  },
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onSidebarButtonPressed;
  final VoidCallback onProfileButtonPressed;
  final String? photoURL;

  String? headerTile;

  CustomHeader({
    required this.focusedDay,
    required this.onSidebarButtonPressed,
    required this.onProfileButtonPressed,
    this.photoURL,
  }) {
    this.headerTile = DateFormat.MMMM('ko_KR').format(focusedDay);
    if (focusedDay.year != DateTime.now().year) {
      headerTile = DateFormat.yMMMM('ko_KR').format(focusedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.menu,
              size: 32,
            ),
            onPressed: onSidebarButtonPressed,
          ),
          Text(
            headerTile!,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18.0,
              color: ColorPalette.PRIMARY_COLOR[400],
            ),
          ),
          photoURL != null
              ? Padding(
                  // (icon_button.dart) it defaults to 8.0 padding on all sides.
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: onProfileButtonPressed,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(photoURL!),
                      radius: 16,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    size: 32,
                  ),
                  onPressed: onProfileButtonPressed,
                ),
        ],
      ),
    );
  }
}

class CustomCalendarBuilder extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final Map<String, List<Map<String, dynamic>>>? events;

  Color? dayColor = Colors.black;
  double isTargetDay = 0.0;
  FontWeight? dayFontWeight = FontWeight.w400;
  Color? isSelected;

  CustomCalendarBuilder({
    super.key,
    required this.day,
    required this.focusedDay,
    this.events,
    this.dayColor,
    this.dayFontWeight,
    this.isSelected,
  }) {
    DateTime today = DateTime.now();
    if (day.year == today.year &&
        day.month == today.month &&
        day.day == today.day) {
      isTargetDay = 1.0;
      dayColor = Colors.white;
      dayFontWeight = FontWeight.w400;
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = calculateFontSize(context);

    return Container(
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isSelected ?? Colors.transparent,
          border: Border(
              top: BorderSide(
            color: Color(0xFFE8EBED),
            width: 0.5,
          )),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(161616.0),
                child: Container(
                  color:
                      ColorPalette.PRIMARY_COLOR[400]!.withOpacity(isTargetDay),
                  width: 24,
                  height: 24,
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: dayFontWeight,
                        color: dayColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                //color: Colors.yellow.withOpacity(0.3),
                child: LayoutBuilder(builder: (context, constraints) {
                  double totalHeight = 0;
                  int displayEvents = 0;
                  int remainingEvents = 0;

                  List<Widget> eventWidgets = [];

                  if (events?[DateFormat('yyyy-MM-dd').format(day)] != null) {
                    for (var event
                        in events![DateFormat('yyyy-MM-dd').format(day)]!) {
                      final bool isAllDay =
                          event['start']['dateTime'] == null ? false : true;
                      final text = event['summary'];
                      // TODO. lineHeight / fontSize
                      final textStyle = TextStyle(
                        color: isAllDay
                            ? ColorPalette.PRIMARY_COLOR[300]!
                            : Colors.white,
                        fontSize: fontSize,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.05,
                      );
                      final textSpan = TextSpan(text: text, style: textStyle);
                      final textPainter = TextPainter(
                        text: textSpan,
                        maxLines: 1,
                        textDirection: ui.TextDirection.ltr,
                      );
                      textPainter.layout(maxWidth: constraints.maxWidth);

                      // final isOverflow = textPainter.didExceedMaxLines ||
                      //     textPainter.width > constraints.maxWidth;

                      final textHeight =
                          textPainter.height + (2.0 + 4.0); // Add padding + 2
                      // print(
                      //     '${day}: ${totalHeight} + ${textHeight} > ${constraints.maxHeight}');
                      if (totalHeight + textHeight > constraints.maxHeight) {
                        remainingEvents++;
                      } else {
                        totalHeight += textHeight;
                        displayEvents++;
                        eventWidgets.add(ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            child: Container(
                              //margin: const EdgeInsets.symmetric(horizontal: 1.0),
                              color: isAllDay
                                  ? ColorPalette.PRIMARY_COLOR[300]!
                                      .withOpacity(0.15)
                                  : ColorPalette.PRIMARY_COLOR[300]!,
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

                    if (remainingEvents > 0) {
                      remainingEvents += 1;
                      displayEvents -= 1;
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
                }),
              ),
            ),
          ],
        ),
      ),
    );
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
}
