import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/screens/calendar/main_calendar.dart';
import 'package:mobile_client/screens/calendar/schedule_bottom_sheet.dart';
import 'package:mobile_client/screens/calendar/utils.dart';
import 'package:mobile_client/screens/preference/preference_view.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with SingleTickerProviderStateMixin {
  // TODO. SingleTickerProviderStateMixin
  DateTime _focusedDay = DateTime.now();

  DateTime selectedDate = DateTime.utc(
    // ➋ 선택된 날짜를 관리할 변수
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // final AnimationController _controller = AnimationController(
  //   duration: const Duration(milliseconds: 500),
  // );

  static const List<IconData> icons = [
    Icons.sms,
    Icons.mail,
    Icons.phone,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    //scopes: <String>[GoogleAPI.CalendarApi.calendarScope],
    scopes: [
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  GoogleSignInAccount? _currentUser;
  late Future<Map<String, dynamic>?> _calendarData;

  final String timeMin = '2024-08-01T00:00:00Z';
  final String timeMax = '2024-08-31T23:59:59Z';

  @override
  void initState() {
    super.initState();
    print('=================================================== initState');
    fetchAndSignIn();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _showSidebarModal(BuildContext context) {
    showModalSideSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            //color: Colors.white,
            //ColorPalette.GRAY_COLOR[100]!, //Colors.yellow.withOpacity(0.3),
            child: Column(
              children: [
                ListTile(
                  title: Text('Item 1'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Item 2'),
                  onTap: () {},
                ),
                // Add more items as needed
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchCalendarData() async {
    print(
        '=================================================== start fetchCalendarData');
    http.Client client = http.Client();
    var headers = await _currentUser?.authHeaders;
    var resp = await client.get(Uri.parse(
            // "https://www.googleapis.com/calendar/v3/users/me/calendarList"),
            "https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=${timeMin}&timeMax=${timeMax}"),
        headers: headers);
    print('status code: ${resp.statusCode}');
    return jsonDecode(resp.body) as Map<String, dynamic>;
    print('====================');
    print('headers: ${headers}');
    // print(_calendarData);
    print('====================');
    // for (var i = 0; i < _calendarData?['items'].length; i++) {
    //   print(_calendarData?['items'][i]['summary']);
    // }
  }

  Future<void> fetchAndSignIn() async {
    await _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        if (_currentUser != null) {
          _calendarData = fetchCalendarData();
          print(
              '=================================================== end fetchCalendarData');
        }
      });
    });
    await _googleSignIn.signIn().then((GoogleSignInAccount? account) {
      if (account != null) {
        setState(() {
          _currentUser = account;
        });
      }
    });

    // final GoogleSignIn _googleSignIn = GoogleSignIn();
    // _currentUser = await _googleSignIn.signInSilently();
    // if (_currentUser == null) {
    //   _currentUser = await _googleSignIn.signIn();
    // }
  }

  @override
  Widget build(BuildContext context) {
    print('=================================================== build');
    return Scaffold(
      floatingActionButton: SpeedDial(
        backgroundColor: ColorPalette.PRIMARY_COLOR[400],
        icon: Icons.add,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(161616.0),
            // ),
            shape: CircleBorder(),
            child: const Icon(Icons.text_decrease, // arrow_circle_down_rounded,
                color: Colors.white),
            label: '수동으로 등록',
            backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isDismissible: true, // 배경 탭했을 때 BottomSheet 닫기
                isScrollControlled: true,
                builder: (_) => ScheduleBottomSheet(),
              );
            },
          ),
          SpeedDialChild(
            shape: CircleBorder(),
            child: const Icon(
              Icons.chat, //email,
              color: Colors.white,
            ),
            label: '자연어로 등록',
            backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
            onTap: () {},
          ),
          SpeedDialChild(
            shape: CircleBorder(),
            child: const Icon(
              Icons.voice_chat,
              color: Colors.white,
            ),
            label: '음성 입력',
            backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
            onTap: () {},
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: _calendarData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              // else if (snapshot.hasError) {
              //   return Center(child: Text('Error: ${snapshot.error}'));
              // }

              else if (snapshot.hasData) {
                final cals = snapshot.data!;
                return Column(
                  children: [
                    Container(
                      //color: Colors.red.withOpacity(0.3),
                      child: CustomHeader(
                        focusedDay: _focusedDay,
                        onSidebarButtonPressed: () {
                          _showSidebarModal(context);
                        },
                        onProfileButtonPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PreferenceView(),
                            ),
                          );
                        },
                      ),
                    ),
                    MainCalendar(cals: cals),
                  ],
                );
              } else {
                return Center(child: Text('No data available'));
              }
            }),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    // ➌ 날짜 선택될 때마다 실행할 함수
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}

class RaisedButton extends StatelessWidget {
  const RaisedButton({super.key, required Text child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Icon(
        Icons.star,
      ),
    );
  }
}
// floatingActionButton: new Column(
//   mainAxisSize: MainAxisSize.min,
//   children: new List.generate(icons.length, (int index) {
//     Widget child = new Container(
//       height: 70.0,
//       width: 56.0,
//       alignment: FractionalOffset.topCenter,
//       child: new ScaleTransition(
//         scale: new CurvedAnimation(
//           parent: _controller,
//           curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
//               curve: Curves.easeOut),
//         ),
//         child: new FloatingActionButton(
//           heroTag: null,
//           backgroundColor: backgroundColor,
//           mini: true,
//           child: new Icon(icons[index], color: foregroundColor),
//           onPressed: () {},
//         ),
//       ),
//     );
//     return child;
//   }).toList()
//     ..add(
//       new FloatingActionButton(
//         heroTag: null,
//         child: new AnimatedBuilder(
//           animation: _controller,
//           builder: (BuildContext context, Widget child) {
//             return new Transform(
//               transform: new Matrix4.rotationZ(
//                   _controller.value * 0.5 * math.pi),
//               alignment: FractionalOffset.center,
//               child: new Icon(
//                   _controller.isDismissed ? Icons.share : Icons.close),
//             );
//           },
//         ),
//         onPressed: () {
//           if (_controller.isDismissed) {
//             _controller.forward();
//           } else {
//             _controller.reverse();
//           }
//         },
//       ),
//     ),
// ),

//         floatingActionButton: (
//           children: [
//             RaisedButton(child: Text('Button1')),
//             RaisedButton(child: Text('Button1')),
//           ],
//         ),
//         body: Column(
//           children: [

//           ],
//         ),
//       ),
//     );
//   }
// }

// FloatingActionButton(

//   onPressed: () {

//   },
// ),

// TableCalendar(
//               firstDay: DateTime.utc(2010, 3, 16),
//               lastDay: DateTime.utc(2030, 3, 16),
//               focusedDay: appState.focusedDay,
//               calendarFormat: appState.calendarFormat,
//               onPageChanged: (focusedDay) {
//                 appState.UpdateFocusedDay(focusedDay);
//               },

// Widget _buildDayCell(DateTime day) {
//   // Example schedule list
//   final schedules = [
//     {'date': DateTime(2023, 10, 1), 'event': 'Meeting'},
//     {'date': DateTime(2023, 10, 1), 'event': 'Lunch'},
//     {'date': DateTime(2023, 10, 2), 'event': 'Conference'},
//   ];

//   // Filter schedules for the current day
//   final daySchedules = schedules.where((schedule) {
//     return (schedule['date'] as DateTime)?.day == day.day &&
//         (schedule['date'] as DateTime)?.month == day.month &&
//         (schedule['date'] as DateTime)?.year == day.year;
//   }).toList();

//   return Container(
//     margin: EdgeInsets.all(4.0),
//     padding: EdgeInsets.all(8.0),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.blue),
//       borderRadius: BorderRadius.circular(8.0),
//     ),
//     child: Column(
//       children: [
//         Text(
//           '${day.day}',
//           style: TextStyle(fontSize: 16.0),
//         ),
//         ...daySchedules.map((schedule) {
//           return Text(
//             schedule['event'] as String,
//             style: TextStyle(fontSize: 12.0),
//           );
//         }).toList(),
//       ],
//     ),
//   );
// }

void showModalSideSheet({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
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

class CustomHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onSidebarButtonPressed;
  final VoidCallback onProfileButtonPressed;

  CustomHeader({
    required this.focusedDay,
    required this.onSidebarButtonPressed,
    required this.onProfileButtonPressed,
  });

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
            DateFormat.MMMM('ko_KR').format(focusedDay),
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18.0,
              color: ColorPalette.PRIMARY_COLOR[400],
            ),
          ),
          IconButton(
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
