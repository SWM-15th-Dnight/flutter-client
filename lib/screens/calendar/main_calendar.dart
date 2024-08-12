import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/screens/calendar/event.dart';
import 'package:table_calendar/table_calendar.dart';

class MainCalendar extends StatefulWidget {
  final Map<String, dynamic> cals;

  const MainCalendar({
    super.key,
    required this.cals,
  });

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  //OnDaySelected onDaySelected; // ➊ 날짜 선택 시 실행할 함수
  DateTime _selectedDay = DateTime.now(); // ➋ 선택된 날짜
  DateTime _focusedDay = DateTime.now();

  // final Map<DateTime, List<Event>> events = {
  //   // DateTime(2024, 08, 01): ['Event 1', 'Event 2', 'Event 3'],
  //   // DateTime(2024, 08, 02): ['Event 4', 'Event 5'],
  //   // Add more dates and events as needed
  // };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    Map<String, List<Map<String, dynamic>>> events = {};
    if (widget.cals['items'] == null) {
      return Container();
    }

    for (var i = 0;
        widget.cals['items'] != null && i < widget.cals['items'].length;
        i++) {
      print(widget.cals['items']);
      var stringEventDT;
      if (widget.cals['items'][i]['start']['dateTime'] == null) {
        stringEventDT = widget.cals['items'][i]['start']['date'];
      } else {
        stringEventDT = widget.cals['items'][i]['start']['dateTime'];
      }
      var dateTimeEventDT = DateTime.parse(stringEventDT);
      // print(dateTimeEventDT.runtimeType);
      // print(DateFormat('yyyy-MM-dd').format(dateTimeEventDT));
      // print(DateFormat('yyyy-MM-dd').format(dateTimeEventDT).runtimeType);
      String dateKey = DateFormat('yyyy-MM-dd').format(dateTimeEventDT);
      // print(widget.cals['items'].runtimeType);
      // print(widget.cals['items'][i].runtimeType);

      addEventToMap(events, dateKey, widget.cals['items'][i]);
      // print(events);
      // events.addAll(DateFormat('yyyy-MM-dd').format(dateTimeEventDT).runtimeType: widget.cals?['items'][i]);
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = screenHeight * 0.7;
    return Column(
      children: [
        Container(
          //color: Colors.blue.withOpacity(0.3),
          height: 685,
          child: LayoutBuilder(builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / 7;
            // final cellHeight = calendarHeight / 6;
            return TableCalendar(
              shouldFillViewport: true,
              locale: 'ko_KR',
              firstDay: DateTime(1800, 1, 1),
              lastDay: DateTime(3000, 1, 1),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  //print(day);
                  //events.containsKey(day)) {
                  //print('${day}');
                  // print('${day.runtimeType}');
                  var eventTitle = '';
                  if (events[DateFormat('yyyy-MM-dd').format(day)] != null) {
                    eventTitle =
                        '${events[DateFormat('yyyy-MM-dd').format(day)]!.length}';
                  }

                  //if (cals?['item']['start'])
                  return Container(
                    width: cellWidth,
                    child: Container(
                      //color: Colors.orange.withOpacity(0.4),
                      //margin: const EdgeInsets.all(4.0),
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFE8EBED),
                              width: 0.5,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(1.0),
                          //color: Colors.blue[200],
                        ),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                '${day.day}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            // ...events[day]!.map((event) => Text(
                            //       //event,
                            //       'asdf',
                            //       style: TextStyle(fontSize: 12.0),
                            //     ))
                            Text(eventTitle),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                // selectedBuilder: (context, day, focusedDay) => DaisyWidget()
                //     .buildCalendarDay(
                //         day: date.day.toString(), backColor: DaisyColors.main4Color),
                outsideBuilder: (context, day, focusedDay) {
                  return Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
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
                          child: Text(
                            '${day.day}',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return Container(
                    padding: const EdgeInsets.all(1.5),
                    width: cellWidth,
                    //margin: const EdgeInsets.all(4.0),
                    //padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorPalette.PRIMARY_COLOR[400]!,
                          width: 0.8), // Red border for today's date
                      borderRadius: BorderRadius.circular(3.0),
                      //color: Colors.blue[200],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                        // Add more widgets if needed
                      ],
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    width: cellWidth,
                    // margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.all(1.5),
                    // padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorPalette.SECONDARY_COLOR[400]!,
                          width: 0.8), // Green border for selected day
                      borderRadius: BorderRadius.circular(3.0),
                      //color: Colors.blue[200],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                        // Add more widgets if needed
                      ],
                    ),
                  );
                },
              ),
              onPageChanged: _onPageChanged,
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

                // headerTitleBuilder: (context, date) {
                //   return Row(
                //     children: [],
                //   );
                // },
              ),
              daysOfWeekHeight: 30.0,
              daysOfWeekStyle: DaysOfWeekStyle(
                  //weekendStyle: TextStyle(color: Colors.red),
                  ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.black),
                //weekendTextStyle: TextStyle(color: Colors.red),
                cellMargin: EdgeInsets.symmetric(vertical: 12.0),
              ),
            );
          }),
        ),
      ],
    );
  }
}
