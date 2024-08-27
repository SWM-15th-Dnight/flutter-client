import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_client/screens/root/root_view.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/entities/user.dart';
import 'package:mobile_client/widget/custom_sidebar_modal.dart';
import '../../common/component/header_text.dart';
import '../../common/const/data.dart';
import '../../services/auth_service.dart';
import '../../widget/custom_event_sheet.dart';
import '../../widget/custom_speed_dial.dart';
import '../preference/preference_view.dart';
import 'form_bottom_sheet.dart';

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

  List<dynamic>? calendarList;
  Set<int> calendarIdSet = {};

  int? currentCalendarId; // assign at getCalendarList()
  Set<int>? displayCalendarIdSet = {}; // assign at getCalendarList()

  //calendarList![currentCalendarId!]['colorSetId']
  Map<int, Color> calendarColorMap = {};

  List<dynamic>? eventList = [];
  bool isGetEventListDone = false;

  File? image;

  @override
  void initState() {
    super.initState();
    user = widget.auth.getCurrentUser();
    // set _selectedDay to 00:00:00.000Z
    _selectedDay = parseUTCDateTime(
        '${DateTime.now().toIso8601String().split('T')[0]}T00:00:00.000Z');
    _loadImage();

    //fetchCalendarData();
    getCalendarList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime parseUTCDateTime(String value) {
    List<String> parts =
        value.contains('T') ? value.split('T') : value.split(' ');
    if (parts.length == 2) {
      final timePart = parts[1];
      if (timePart.endsWith('Z') ||
          timePart.contains('+') ||
          timePart.contains('-')) {
        return DateTime.parse(value);
      } else {
        return DateTime.parse('${value}Z');
      }
    }
    return DateTime.parse(value);
  }

  // TODO.
  Future<void> _refreshCalendar() async {
    // Implement your refresh logic here
    await getEventList();
  }

  void _onPageChanged(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      DateTime today = DateTime.now();
      if (focusedDay.year == today.year && focusedDay.month == today.month) {
        _selectedDay = today;
      } else {
        _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
      }
    });
  }

  void showDaysEventsModal(BuildContext parentContext,
      Map<String, List<Map<String, dynamic>>> dateEvents) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      builder: (BuildContext context) {
        var day = DateFormat('yyyy-MM-dd').format(_selectedDay);
        var numberOfEvents = dateEvents[day]?.length ?? 0;
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  // TODO. Text 상단 고정하고, bottom overflow시 스크롤되게
                  const SizedBox(height: 20.0),
                  Text(
                    '${DateFormat('M월 d일').format(_selectedDay)}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                      child: ListView(
                    children: [
                      for (var event in dateEvents[day] ?? [])
                        ListTile(
                          title: Text(
                            event['summary'],
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                          subtitle: Text(
                            '${DateFormat('HH:mm').format(DateTime.parse(event['startAt']))} ~ ${DateFormat('HH:mm').format(DateTime.parse(event['endAt']))}',
                            style: TextStyle(
                              fontSize: 10.0,
                            ),
                          ),
                          onTap: () {
                            print(event);
                            Navigator.pop(context);
                            _showEventDetailModal(
                                context, event, parentContext, dateEvents);
                          },
                        ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEventDetailModal(
      BuildContext context,
      Map<String, dynamic> event,
      BuildContext parentContext,
      Map<String, List<Map<String, dynamic>>> dateEvents) {
    showModalBottomSheet(
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return CustomEventSheet(
          event: event,
          parentContext: parentContext,
          dateEvents: dateEvents,
          showDaysEventsModal: showDaysEventsModal,
          eventList: eventList,
          updateEventList: updateEventList,
          onEventEdited: _editEventToList,
        );
      },
    );
  }

  void updateEventList(List<dynamic>? newEventList) {
    setState(() {
      eventList = newEventList;
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

  Future<void> getCalendarList() async {
    print('getCalendarList()');
    await widget.auth.checkToken();
    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    var resp = await dio.get(
        dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/calendars/',
        options: Options(headers: {'authorization': 'Bearer $refreshToken'}));
    print('getCalendarList() resp: $resp');
    print('getCalendarList() resp: ${resp.statusCode}');
    print('getCalendarList() resp: ${resp.data.runtimeType}');
    setState(() {
      calendarList = resp.data;
      print('현재 캘린더 아이디: ${currentCalendarId}');
      print('비교할 아이디: ${calendarList![0]['calendarId']}');
      currentCalendarId = currentCalendarId ?? calendarList![0]['calendarId'];
      // TODO. 기본 캘린더 번호를 2로 가정해버렸음, 그냥 지웠음
      // howSnackbar('현재 ${currentCalendarId! - 2}번 캘린더가 선택되었습니다!');
      displayCalendarIdSet?.add(currentCalendarId!);
      for (var cal in calendarList!) {
        calendarIdSet.add(cal['calendarId']);
      }
    });

    await makeCalendarColorMap();
  }

  Future<void> makeCalendarColorMap() async {
    print('makeCalendarColorMap()');
    await widget.auth.checkToken();
    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    print('refreshToken: $refreshToken');

    var resp = await dio.get(
      dotenv.env['BACKEND_MAIN_URL']! + '/colorSet/',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    for (var cal in calendarList!) {
      for (var r in resp.data) {
        //print(r['hexCode'].substring(1));
        if (cal['colorSetId'] == r['colorSetId']) {
          calendarColorMap[cal['calendarId']] = hexToColor(r['hexCode']);
          break;
        }
      }
    }

    await getEventList();
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> getEventList() async {
    //print('getEventList()');
    await widget.auth.checkToken();
    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    eventList = [];

    for (var i = 1; i < 100; i++) {
      try {
        var resp = await dio.get(
            dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/event/${i}',
            options:
                Options(headers: {'authorization': 'Bearer $refreshToken'}));
        if (resp.statusCode == 200) {
          //print('getEventList() : ${resp.data}');
          eventList?.add(resp.data);
        }
      } catch (e) {}
    }
    print('eventList.length: ${eventList?.length}');
    setState(() {
      isGetEventListDone = true;
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
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

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null) {
      setState(() {
        image = File(imagePath);
      });
    }
  }

  void _addEventToList(dynamic event) {
    setState(() {
      eventList?.add(event);
    });
  }

  Future<void> _editEventToList(int eventId) async {
    setState(() {
      eventList?.removeWhere((element) => element['eventId'] == eventId);
    });

    var _event = await MainRequest().getEvent(eventId);

    setState(() {
      eventList?.add(_event.data);
    });
  }

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

    if (!isGetEventListDone) {
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

    // TODO. Range Event
    Map<String, List<Map<String, dynamic>>> dateEvents = {};

    if (eventList?.length != 0) {
      for (var i = 0; i < eventList!.length; i++) {
        //print('[$i] : ${eventList![i]}');
        String dateKey = DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(eventList![i]['startAt']));
        //print('dateKey: $dateKey');
        if (displayCalendarIdSet!.contains(eventList![i]['calendarId'])) {
          addEventToMap(dateEvents, dateKey, eventList![i]);
        }
      }
    }

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      floatingActionButton: Align(
        alignment: Alignment(0.96, 0.99),
        // TODO. 따라서 사이드바에서 토스트가 떠야하고, 입력 폼에서 currentCalendarId가 보여져야 한다.
        child: CustomSpeedDial(
          currentCalendarId: currentCalendarId,
          onEventAdded: _addEventToList,
          auth: widget.auth,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CustomHeader(
                  focusedDay: _focusedDay,
                  onSidebarButtonPressed: () {
                    showModalSideSheet(
                      context: context,
                      builder: (context) {
                        return CustomSidebarModal(
                          calendarList: calendarList,
                          currentCalendarId: currentCalendarId,
                          displayCalendarIdSet: displayCalendarIdSet,
                          onCalendarSelected: (int selectedCalendarId) {
                            print(
                                '(MainCalendar) Selected calendarId: ${selectedCalendarId}');
                            setState(() {
                              currentCalendarId = selectedCalendarId;
                            });
                            showSnackbar(
                                '현재 ${currentCalendarId}번 캘린더가 선택되었습니다!');
                          },
                          onSelectedCalendarDeleted: (int primaryCalendarId) {
                            setState(() {
                              currentCalendarId = primaryCalendarId;
                            });
                          },
                          onCalendarCreated: getCalendarList,
                        );
                      },
                    );
                  },
                  onProfileButtonPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PreferenceView(
                          auth: widget.auth,
                          currentCalendar: calendarList!.firstWhere(
                              (calendar) =>
                                  calendar['calendarId'] == currentCalendarId),
                          onCalendarModified: getCalendarList,
                        ),
                      ),
                    );
                  },
                  image: image,
                ),
                Expanded(
                  child: TableCalendar(
                    locale: 'ko_KR',
                    // notice. TableCalendar should be in Container
                    shouldFillViewport: true,
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(1800, 1, 1),
                    lastDay: DateTime.utc(3000, 1, 1),
                    onPageChanged: (focusedDay) {
                      _onPageChanged(_selectedDay, focusedDay);
                    },
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
                        print('selectdDay: ${_selectedDay}, ${selectedDay}');
                        if (_selectedDay == selectedDay) {
                          print('double tab!');
                          showDaysEventsModal(context, dateEvents);
                        }
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        print('selectdDay: ${_selectedDay} ${selectedDay}');
                      });
                    },
                    // TODO. onDayLongPressed
                    //onDayLongPressed: ,
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return CustomCalendarBuilder(
                          day: day,
                          focusedDay: focusedDay,
                          events: dateEvents,
                          calendarColorMap: calendarColorMap,
                        );
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return CustomCalendarBuilder(
                          day: day,
                          focusedDay: focusedDay,
                          dayColor: Color(0XFFAAAAAA),
                          events: dateEvents,
                          calendarColorMap: calendarColorMap,
                        );
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return CustomCalendarBuilder(
                          day: day,
                          focusedDay: focusedDay,
                          events: dateEvents,
                          calendarColorMap: calendarColorMap,
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
                          calendarColorMap: calendarColorMap,
                          isSelected: ColorPalette.PRIMARY_COLOR[400]!
                              .withOpacity(0.05),
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
                /*
                Flexible(
                  flex: 10,
                  child: ,
                ),
                */
                /*
                Flexible(
                  flex: 1,
                  child: Container(),
                )
                */
              ],
            ),
            // TODO.
            //FormBottomSheet(),
          ],
        ),
      ),
    );
  }

  void showModalSideSheet({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    showGeneralDialog(
      context: context,
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      //barrierColor: Colors.black, // turn off the background color
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            child: builder(context),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}

class CustomHeader extends StatefulWidget {
  final DateTime focusedDay;
  final VoidCallback onSidebarButtonPressed;
  final VoidCallback onProfileButtonPressed;
  String? headerTile;
  File? image;

  CustomHeader({
    required this.focusedDay,
    required this.onSidebarButtonPressed,
    required this.onProfileButtonPressed,
    this.image,
  }) {
    this.headerTile = DateFormat.MMMM('ko_KR').format(focusedDay);
    if (focusedDay.year != DateTime.now().year) {
      headerTile = DateFormat.yMMMM('ko_KR').format(focusedDay);
    }
  }

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  @override
  void initState() {
    super.initState();
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
            onPressed: widget.onSidebarButtonPressed,
          ),
          HeaderText(text: widget.headerTile!),
          widget.image != null
              ? Padding(
                  // (icon_button.dart) it defaults to 8.0 padding on all sides.
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: widget.onProfileButtonPressed,
                    child: CircleAvatar(
                      backgroundImage: FileImage(widget.image!),
                      radius: 16,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    size: 32,
                  ),
                  onPressed: widget.onProfileButtonPressed,
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
  final Map<int, Color> calendarColorMap;

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
    required this.calendarColorMap,
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
                      var startAtTime = DateFormat('HH:mm:ss')
                          .format(DateTime.parse(event['startAt']));
                      var endAtTime = DateFormat('HH:mm:ss')
                          .format(DateTime.parse(event['endAt']));

                      final bool isAllDay = (startAtTime == '00:00:00') &&
                              (endAtTime == '00:00:00')
                          ? false
                          : true;
                      final text = event['summary'];
                      // TODO. lineHeight / fontSize
                      final textStyle = TextStyle(
                        color: isAllDay
                            ? calendarColorMap[event['calendarId']]
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
                      if (totalHeight + textHeight + textHeight >
                          constraints.maxHeight) {
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
                                  ? calendarColorMap[event['calendarId']]!
                                      .withOpacity(0.15)
                                  : calendarColorMap[event['calendarId']],
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
                      //remainingEvents += 1;
                      //displayEvents -= 1;
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
