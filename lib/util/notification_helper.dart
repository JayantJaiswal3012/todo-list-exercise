import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart';

import '../constants.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
DateTime selectedDate;

Future<void> initNotifications() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
  });
  _configureLocalTimeZone();
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<void> scheduleNotification(
    String id, String body, DateTime scheduledNotificationDateTime) async {
  print('Notification scheduled $body');
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    id,
    'Reminder notification',
    'Remember about it',
    icon: '@mipmap/ic_launcher',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  final scheduledDateTime = tz.TZDateTime.from(scheduledNotificationDateTime, tz.local);

  await flutterLocalNotificationsPlugin.zonedSchedule(int.parse(id.substring(id.length-7)), Const.TODO_REMINDER,
      body, scheduledDateTime, platformChannelSpecifics,
      androidAllowWhileIdle: true);
}

Future<void> cancelNotification(String id) async {
  print('Notification cancelled $id');
  await flutterLocalNotificationsPlugin.cancel(int.parse(id.substring(id.length-7)));
}
