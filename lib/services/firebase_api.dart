import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_client/main.dart';
import 'package:mobile_client/widget/notification_test.dart';

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState
        ?.pushNamed(NotificationTest.route, arguments: message);
  }

  Future initPushNotifications() async {
    print(
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: ${_calendarNotificationChannel.id}');
    print(
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: ${_calendarNotificationChannel.name}');

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      await _localNotifications.show(
        0, //notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _calendarNotificationChannel.id,
            _calendarNotificationChannel.name,
            channelDescription: _calendarNotificationChannel.description,
            importance: _calendarNotificationChannel.importance,
            priority: Priority.high,
            fullScreenIntent: true,
            // TODO. icon
            icon: '@mipmap/ic_launcher',
            playSound: true,
            //sound: RawResourceAndroidNotificationSound('notification'),
            ticker: 'ticker',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );

      print('title?: ${message.notification?.title}');
      print('body?: ${message.notification?.body}');
      print('payload?: ${message.data}');
    });
  }

  Future initLocalNotifications() async {
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: ${_calendarNotificationChannel.id}');
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: ${_calendarNotificationChannel.name}');

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_calendarNotificationChannel);
    final androidInitialize = AndroidInitializationSettings('ic_launcher');
    await _localNotifications.initialize(
      InitializationSettings(android: androidInitialize),
    );
  }

  final _calendarNotificationChannel = const AndroidNotificationChannel(
    'notify_calendar', // id
    '일정 알림', // title
    description: '예정된 일정에 대한 알림 입니다.',
    importance: Importance.max,
    playSound: true,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> getFCMToken() async {
    final fcmToken = await _firebaseMessaging.getToken();
    print('fcmToken: ${fcmToken}');
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    await getFCMToken();
    initPushNotifications();
    initLocalNotifications();
  }
}
