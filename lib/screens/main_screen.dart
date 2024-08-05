import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    print('< SignInPage >');
    User? signedUser = null;

    if (FirebaseAuth.instance.currentUser != null) {
      signedUser = FirebaseAuth.instance.currentUser;
    } else {
      print('Signed null currentUser error');
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Calinify'),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 3, 16),
              lastDay: DateTime.utc(2030, 3, 16),
              focusedDay: appState.focusedDay,
              calendarFormat: appState.calendarFormat,
              onPageChanged: (focusedDay) {
                appState.UpdateFocusedDay(focusedDay);
              },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('email: ${signedUser?.email}'),
                  SizedBox(height: 10),
                  Text('displayName: ${signedUser?.displayName}'),
                  SizedBox(height: 10),
                  Text('uid: ${signedUser?.uid}'),
                  SizedBox(height: 20),
                  //Text(
                  //    'idToken: ${idToken != null && idToken!.length > 20 ? "...${idToken!.substring(idToken!.length - 10)}" : idToken}'),
                  Text(
                    'idToken: ${idToken}',
                    style: TextStyle(fontSize: 8),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      appState.signOut();
                      //logger.d("test2: ${idToken}");
                    },
                    child: Text('로그아웃'),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
