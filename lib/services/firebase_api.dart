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
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: ${_androidNotificationChannel.id}');
    print(
        '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!: ${_androidNotificationChannel.name}');

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
            _androidNotificationChannel.id,
            _androidNotificationChannel.name,
            channelDescription: _androidNotificationChannel.description,
            // TODO. icon
            icon: '@mipmap/ic_launcher',
            playSound: true,
            //sound: RawResourceAndroidNotificationSound('notification'),
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            //category: NotificationCompat.CATEGORY_ALARM,
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
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidNotificationChannel);
    final androidInitialize = AndroidInitializationSettings('ic_launcher');
    await _localNotifications.initialize(
      InitializationSettings(android: androidInitialize),
      /*
      onSelectNotification: (String? payload) async {
        if (payload == null) return;

        final message = RemoteMessage.fromMap(jsonDecode(payload));
        navigatorKey.currentState
            ?.pushNamed(NotificationTest.route, arguments: message);
      },
      */
    );
  }

  final _androidNotificationChannel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
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
