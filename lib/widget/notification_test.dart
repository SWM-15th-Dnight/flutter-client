import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationTest extends StatelessWidget {
  const NotificationTest({super.key});
  static const route = '/notification_test';

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${message.notification?.title}'),
            Text('${message.notification?.body}'),
            Text('${message.data}'),
          ],
        ),
      ),
    );
  }
}
