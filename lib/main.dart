import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'task_list_screen.dart';

void main() {
  AwesomeNotifications().initialize("resource://drawable/notifications_1", [
    NotificationChannel(
      channelKey: 'alerts',
      channelName: 'Alerts',
      defaultColor: Colors.teal,
      channelDescription: '',
      importance: NotificationImportance.High,
      channelShowBadge: true,
    )
  ]);
  runApp(MyApp());
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print("Notificatuon _______________ $receivedNotification ___________ ");
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    AwesomeNotifications()
        .getGlobalBadgeCounter()
        .then((value) => AwesomeNotifications().setGlobalBadgeCounter(value));
    print(" 2222    _______________ $receivedNotification ___________ ");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print("111_______________ $receivedAction ___________ ");
    }
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("2222222_______________ $receivedAction ___________ ");

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}
