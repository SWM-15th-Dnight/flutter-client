import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_client/screens/preference/preference_view.dart';
import 'package:mobile_client/screens/root/root_view.dart';
import 'package:mobile_client/services/firebase_api.dart';
import 'package:mobile_client/widget/notification_test.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'package:mobile_client/common/view/splash_screen.dart';
import 'package:mobile_client/screens/home/home_view_model.dart';
import 'package:mobile_client/screens/root/root_view_model.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /* Firebase Cloud Message */
  FirebaseApi().initNotification();

  runApp(ProviderScope(child: _App()));
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ko', ''),
      ],
      navigatorKey: navigatorKey,
      home: SplashScreen(),
      routes: {
        // PreferenceView.route: (context) => PreferenceView(auth: null, currentCalendar: {}, onCalendarModified: null,),
        NotificationTest.route: (context) => NotificationTest(),
      },
    );
  }
}
