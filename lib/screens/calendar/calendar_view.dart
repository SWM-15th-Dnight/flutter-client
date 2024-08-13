import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_client/screens/calendar/main_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
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

  final String timeMin = '2023-01-01T00:00:00Z';
  final String timeMax = '2024-08-31T23:59:59Z';

  @override
  void initState() {
    super.initState();
    print('=================================================== initState');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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

  Future<Map<String, dynamic>?> fetchAndSignIn() async {
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
    return _calendarData;
  }

  @override
  Widget build(BuildContext context) {
    print('=================================================== build');
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          FutureBuilder(
            future: fetchAndSignIn(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                //snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                //if (snapshot.hasData) {
                return Container(); // MainCalendar();
              }
            },
          ),
        ],
      )),
    );
  }
}
