import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/component/custom_app_bar.dart';
import 'package:mobile_client/common/component/loading_indicators.dart';
import 'package:mobile_client/screens/event/event_month_view.dart';
import 'package:mobile_client/screens/root/root_view.dart';
import 'package:mobile_client/screens/signIn/sign_in_view.dart';
import 'package:mobile_client/services/dio_client.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/widget/custom_sidebar_modal.dart';
import '../../common/component/header_text.dart';
import '../../common/component/service_name_text.dart';
import '../../common/component/snackbar_helper.dart';
import '../../common/const/data.dart';
import '../../common/layout/default_layout.dart';
import '../../entities/calendar.dart';
import '../../entities/event.dart';
import '../../entities/event_list.dart';
import '../../services/auth_service.dart';
import '../../widget/custom_event_sheet.dart';
import '../../widget/custom_speed_dial.dart';
import '../preference/preference_view.dart';
import '../../entities/color_map.dart';
import '../../widget/modal.dart';

GlobalKey _calendarKey = GlobalKey();

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

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // TODO.
  final String timeMin = '2023-01-01T00:00:00Z';
  final String timeMax = '2024-12-31T23:59:59Z';

  Map<int, Calendar> calendarMap = {};
  int? currentCalendarId; // assign at getCalendarMap()

  ColorMap colorMap = ColorMap();

  ColorMap getColorMap() {
    return colorMap;
  }

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
    getCalendarMap();
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

  void showDaysEventsModal(
      BuildContext parentContext, List<DisplayEvent>? display) {
    List<DisplayEvent> filtered = [];
    for (DisplayEvent event in (display ?? [])) {
      if (event.isEmpty == false) filtered.add(event);
    }

    return modal(
      parentContext,
      DateFormat('M월 d일 (EE)', 'ko_KR').format(_selectedDay),
      ListView(
        children: [
          for (DisplayEvent event in (filtered ?? []))
            ListTile(
              title: Text(
                event.summary,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              subtitle: Text(
                '${DateFormat('aa h:mm', 'ko_KR').format(event.startAt)} ~ ${DateFormat('aa h:mm', 'ko_KR').format(event.endAt)}',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
              onTap: () {
                print(event);
                Navigator.pop(context);
                _showEventDetailModal(context, event, parentContext, display);
              },
            ),
        ],
      ),
    );
  }

  void _showEventDetailModal(
    BuildContext context,
    DisplayEvent event,
    BuildContext parentContext,
    List<DisplayEvent>? display,
  ) {
    showModalBottomSheet(
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return CustomEventSheet(
          event: event,
          parentContext: parentContext,
          display: display,
          showDaysEventsModal: showDaysEventsModal,
          onEventEdited: _renewEvent,
        );
      },
    );
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

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getCalendarMap() async {
    print('[main_calendar.dart] getCalendarMap()');
    await widget.auth.checkToken();
    var resp;
    try {
      resp = await DioClient()
          .get('${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/calendars/');
    } catch (e) {
      widget.auth.signOut();
      showSnackbar(context, '캘린더 정보를 불러오는 중 오류가 발생했습니다.');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RootView(auth: widget.auth)));
    }

    var firstId;
    Map<int, Calendar> calMap = {};
    print('resp.data.length: ${resp.data.length}');

    if (resp.data.length == 0) {
      print('[main_calendar.dart] No calendar data');
      // 첫 로그인 시 캘린더가 하나도 없을 경우, 기본 캘린더 생성하기
      var data = {"title": "기본 캘린더", "timezone": "Asia/Seoul", "colorSetId": 1};
      try {
        resp = await DioClient()
            .post('${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/calendars/', data);
      } catch (e) {
        widget.auth.signOut();
        showSnackbar(context, '캘린더 생성에 오류가 발생했습니다.');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RootView(auth: widget.auth)));
      }
      // 다시 캘린더 데이터 불러오기
      try {
        resp = await DioClient()
            .get('${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/calendars/');
      } catch (e) {
        widget.auth.signOut();
        showSnackbar(context, '캘린더 정보를 불러오는 중 오류가 발생했습니다.');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RootView(auth: widget.auth)));
      }
    }

    for (var cal in resp.data) {
      var elem = Calendar(cal);
      elem.setColorMap(colorMap);
      firstId = firstId ?? elem.id;
      calMap[elem.id] = elem;
    }

    setState(() {
      calendarMap = calMap;

      print('현재 캘린더 아이디: ${currentCalendarId}');
      print('비교할 아이디: ${firstId}');
      currentCalendarId = currentCalendarId ?? firstId;
    });

    await getEventList();
  }

  Future<void> getEventList() async {
    print('[main_calendar.dart] getEventList()');
    await widget.auth.checkToken();

    try {
      var resp = await DioClient().get(
        '${dotenv.env['BACKEND_MAIN_URL']!}/eventList/all',
        queryParameters: {
          'timeMin': timeMin,
          'timeMax': timeMax,
        },
      );
      if (resp.statusCode == 200) {
        print(resp.data);
        for (var curr in resp.data) {
          Event event = Event.parse(curr);
          event.colorSetId =
              calendarMap[event.calendarId]!.colorSetId; // temp function
          EventList.Add(calendarMap, event: event);
        }
      }
    } catch (e) {
      print("ERROR OCCURED ${e}");
    }

    setState(() {
      isGetEventListDone = true;
    });
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

  void _addEvent(dynamic input) {
    setState(() {
      EventList.Add(calendarMap, input: input);
    });
  }

  void _delEvent(int eventId) async {
    setState(() {
      EventList.Delete(calendarMap, eventId);
    });
  }

  Future<void> _renewEvent(int eventId) async {
    _delEvent(eventId);
    var _event = await MainRequest().getEvent(eventId);
    _addEvent(_event.data);
  }

  Future<void> _captureCalendar() async {
    try {
      RenderRepaintBoundary boundary = _calendarKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 80,
          name: 'calinify_${DateTime.now().toIso8601String()}',
        );

        if (result['isSuccess']) {
          showSnackbar(context, '캘린더 캡처 이미지가 저장 되었습니다.');
        } else {
          showSnackbar(context, '캘린더 캡처 이미지 저장에 실패했습니다.');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isGetEventListDone) {
      return DefaultLayout(
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                color: ColorPalette.GRAY_COLOR[50]!,
              ),
              Transform.translate(
                offset: Offset(0, -20),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '일정 정보를 불러오고 있어요!',
                        style: TextStyle(
                          color: ColorPalette.PRIMARY_COLOR[300]!,
                          fontWeight: FontWeight.w300,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: LoadingIndicators(
                            color: ColorPalette.PRIMARY_COLOR[400]!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // TODO. Range Event
    Map<DateTime, List<DisplayEvent>> display =
        EventList.AsDisplay(calendarMap);

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      floatingActionButton: Align(
        alignment: Alignment(0.96, 0.99),
        // TODO. 따라서 사이드바에서 토스트가 떠야하고, 입력 폼에서 currentCalendarId가 보여져야 한다.
        child: CustomSpeedDial(
          currentCalendarId: currentCalendarId,
          onEventAdded: _addEvent,
          auth: widget.auth,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RepaintBoundary(
              key: _calendarKey,
              child: Column(
                children: [
                  Container(
                    color: ColorPalette.GRAY_COLOR[50]!,
                    child: CustomAppBar(
                      leftWidget: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () {
                              showModalSideSheet(
                                context: context,
                                builder: (context) {
                                  return CustomSidebarModal(
                                    colorMap: colorMap,
                                    calendarMap: calendarMap,
                                    currentCalendarId: currentCalendarId,
                                    onCalendarSelected:
                                        (int selectedCalendarId) {
                                      print(
                                          '(MainCalendar) Selected calendarId: ${selectedCalendarId}');
                                      setState(() {
                                        currentCalendarId = selectedCalendarId;
                                      });
                                      showSnackbar(context,
                                          '현재 ${currentCalendarId}번 캘린더가 선택되었습니다!');
                                    },
                                    onSelectedCalendarDeleted:
                                        (int primaryCalendarId) {
                                      setState(() {
                                        currentCalendarId = primaryCalendarId;
                                      });
                                    },
                                    onCalendarCreated: getCalendarMap,
                                  );
                                },
                              );
                            },
                          ),
                          // Spacer IconButton
                          IconButton(
                            icon: Icon(Icons.menu, color: Colors.transparent),
                            onPressed: null,
                          ),
                        ],
                      ),
                      centerContent: _focusedDay,
                      rightWidget: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.save_outlined),
                            onPressed: () async {
                              if (await Permission.storage
                                  .request()
                                  .isGranted) {
                                _captureCalendar();
                              } else {
                                showSnackbar(context, '저장소 권한을 허용해주세요.');
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.account_circle),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PreferenceView(
                                    auth: widget.auth,
                                    currentCalendar:
                                        calendarMap[currentCalendarId]!,
                                    onCalendarModified: getCalendarMap,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: ColorPalette.GRAY_COLOR[50]!,
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
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          print('[main_calendar.dart] onDaySelected');
                          setState(() {
                            print(
                                'selectdDay (1): ${_selectedDay}, ${selectedDay}');
                            if (_selectedDay == selectedDay) {
                              print('double tab!');
                              showDaysEventsModal(
                                  context, display[onlyDate(_selectedDay)]);
                            }
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            print(
                                'selectdDay (2): ${_selectedDay} ${selectedDay}');
                          });
                        },
                        onDayLongPressed: (selectedDay, focusedDay) {
                          print('[main_calendar.dart] onDayLongPressed');
                          setState(() {
                            print(
                                'selectdDay (1): ${_selectedDay}, ${selectedDay}');

                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            showDaysEventsModal(
                                context, display[onlyDate(_selectedDay)]);

                            print(
                                'selectdDay (2): ${_selectedDay} ${selectedDay}');
                          });
                        },
                        eventLoader: (day) => display[day] ?? [],
                        calendarBuilders: CalendarBuilders(
                            defaultBuilder: CustomCalendarBuilder,
                            outsideBuilder: (context, day, focusedDay) {
                              return CustomCalendarBuilder(
                                context,
                                day,
                                focusedDay,
                                dayColor: Color(0XFFAAAAAA),
                              );
                            },
                            todayBuilder: CustomCalendarBuilder,
                            selectedBuilder: CustomCalendarBuilder,
                            markerBuilder: (context, day, focusedDay) {
                              return (Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      //color: Colors.yellow.withOpacity(0.3),
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        return EventMonthViewCell(
                                            context,
                                            constraints,
                                            display[day],
                                            day,
                                            colorMap);
                                      }),
                                    ),
                                  ),
                                ],
                              ));
                            }),
                      ),
                    ),
                  ),
                ],
              ),
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

Widget? CustomCalendarBuilder(context, day, focusedDay,
    {Color dayColor = Colors.black}) {
  Color selectedDay = Colors.transparent;
  Color dayWrapper = Colors.transparent;

  if (onlyDate(DateTime.now()) == onlyDate(day)) {
    dayWrapper = ColorPalette.PRIMARY_COLOR[400]!;
    dayColor = Colors.white;
  }

  if (day == focusedDay) {
    selectedDay = ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.05);
  }

  return Container(
    child: Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: selectedDay,
        border: const Border(
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
                color: dayWrapper,
                width: 24,
                height: 24,
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: dayColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
