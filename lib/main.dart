import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_client/screens/root/root_view.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'package:mobile_client/common/view/splash_screen.dart';
import 'package:mobile_client/screens/home/home_view_model.dart';
import 'package:mobile_client/screens/root/root_view_model.dart';
import 'package:mobile_client/screens/signIn/sign_in_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /* Firebase Cloud Message */
  initNotification();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RootViewModel()),
      ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ChangeNotifierProvider(create: (_) => SignInViewModel()),
    ],
    child: _App(),
  ));
}

Future<void> getFCMToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('fcmToken: ${fcmToken}');
}

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('payload: ${message.data}');
}

Future<void> initNotification() async {
  await FirebaseMessaging.instance.requestPermission();
  await getFCMToken();
  // background & terminated
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
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
      home: SplashScreen(),
    );
  }
}
