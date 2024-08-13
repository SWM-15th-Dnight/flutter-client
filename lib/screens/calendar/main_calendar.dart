import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/screens/calendar/event.dart';
import 'package:mobile_client/screens/calendar/schedule_bottom_sheet.dart';
import 'package:mobile_client/widget/custom_sidebar_modal.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../widget/custom_speed_dial.dart';
import '../preference/preference_view.dart';

class MainCalendar extends StatefulWidget {
  final FBUser fbUser;

  const MainCalendar({
    super.key,
    required this.fbUser,
  });

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  //OnDaySelected onDaySelected; // ➊ 날짜 선택 시 실행할 함수
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<String, dynamic> cals = {
    'items': [
      {
        'start': {'dateTime': '2024-08-01T10:00:00Z'},
        'summary': 'Event 1'
      },
      {
        'start': {'dateTime': '2024-08-02T12:00:00Z'},
        'summary': 'Event 2'
      }
    ]
  };

  // final Map<DateTime, List<Event>> events = {
  //   // DateTime(2024, 08, 01): ['Event 1', 'Event 2', 'Event 3'],
  //   // DateTime(2024, 08, 02): ['Event 4', 'Event 5'],
  //   // Add more dates and events as needed
  // };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.fbUser.uid);
    print(widget.fbUser.photoURL);
  }

  @override
  void dispose() {
    // TODO: implement dispose
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

  @override
  Widget build(BuildContext context) {
    /*
    Map<String, List<Map<String, dynamic>>> events = {};
    if (cals['items'] == null) {
      return Container();
    }

    for (var i = 0; cals['items'] != null && i < cals['items'].length; i++) {
      print(cals['items']);
      var stringEventDT;
      if (cals['items'][i]['start']['dateTime'] == null) {
        stringEventDT = cals['items'][i]['start']['date'];
      } else {
        stringEventDT = cals['items'][i]['start']['dateTime'];
      }
      var dateTimeEventDT = DateTime.parse(stringEventDT);
      // print(dateTimeEventDT.runtimeType);
      // print(DateFormat('yyyy-MM-dd').format(dateTimeEventDT));
      // print(DateFormat('yyyy-MM-dd').format(dateTimeEventDT).runtimeType);
      String dateKey = DateFormat('yyyy-MM-dd').format(dateTimeEventDT);
      // print(widget.cals['items'].runtimeType);
      // print(widget.cals['items'][i].runtimeType);

      addEventToMap(events, dateKey, cals['items'][i]);
      // print(events);
      // events.addAll(DateFormat('yyyy-MM-dd').format(dateTimeEventDT).runtimeType: widget.cals?['items'][i]);
    }
    */

    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = screenHeight * 0.7;
    //final cellWidth = constraints.maxWidth / 7;

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
                    builder: (_) =>
                        PreferenceView(photoURL: widget.fbUser.photoURL),
                  ),
                );
              },
              photoURL: widget.fbUser.photoURL,
            ),
            Flexible(
              //height: 600,
              flex: 10,
              //color: Colors.blue.withOpacity(0.3),
              //     final cellHeight = calendarHeight / 6;
              child: TableCalendar(
                locale: 'ko_KR',
                shouldFillViewport:
                    true, // notice. TableCalendar should be in Container
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(1800, 1, 1),
                lastDay: DateTime.utc(3000, 1, 1),
                onPageChanged: _onPageChanged,
                daysOfWeekHeight: 30.0,
                daysOfWeekStyle: DaysOfWeekStyle(
                    //weekendStyle: TextStyle(color: Colors.red),
                    ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.black),
                  //weekendTextStyle: TextStyle(color: Colors.red),
                  cellMargin: EdgeInsets.symmetric(vertical: 12.0),
                ),
                headerVisible: false,
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible:
                      false, // 달력 크기 선택 옵션 없애기 (ex. 2 Weeks button)
                  // ex. 2024년 8월 -> 8월, import intl
                  // titleTextFormatter: (date, locale) =>
                  //     DateFormat.MMMM(locale).format(date),
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
                    );
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return CustomCalendarBuilder(
                      day: day,
                      focusedDay: focusedDay,
                      dayColor: Colors.grey,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return CustomCalendarBuilder(
                      day: day,
                      focusedDay: focusedDay,
                      /*
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
                      decoration: BoxDecoration(
                        color:
                            ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.05),
                        border: Border.all(
                            color: ColorPalette.SECONDARY_COLOR[400]!
                                .withOpacity(0.0),
                            width: 0.8),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      dayFontWeight: FontWeight.w500,
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

/*


if (events[DateFormat('yyyy-MM-dd').format(day)] !=
    null) {
  eventTitle =
      '${events[DateFormat('yyyy-MM-dd').format(day)]!.length}';
}


          //if (cals?['item']['start'])
*/

class CustomCalendarBuilder extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final String? eventTitle;
  final Map<String, List<Map<String, dynamic>>>? events;
  final BoxDecoration decoration;

  Color? dayColor = Colors.black;
  double isTargetDay = 0.0;
  FontWeight? dayFontWeight = FontWeight.w400;

  CustomCalendarBuilder({
    super.key,
    required this.day,
    required this.focusedDay,
    this.eventTitle = 'asdf',
    this.events,
    this.decoration = const BoxDecoration(
      border: Border(
          top: BorderSide(
        color: Color(0xFFE8EBED),
        width: 0.5,
      )),
    ),
    this.dayColor,
    this.dayFontWeight,
  }) {
    DateTime today = DateTime.now();
    if (day.year == today.year &&
        day.month == today.month &&
        day.day == today.day) {
      print('focusedDay: $focusedDay');
      isTargetDay = 1.0;
      dayColor = Colors.white;
      dayFontWeight = FontWeight.w400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: decoration,
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
            ...?events?[day.toString()]!.map(
              (event) => Text(
                //event,
                'asdf',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Text(eventTitle ?? ''),
          ],
        ),
      ),
    );
  }
}
