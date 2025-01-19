import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lab2_225121/providers/favorites_provider.dart';
import 'package:lab2_225121/screens/favorites_joke.dart';
import 'package:lab2_225121/screens/random_joke.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'screens/main_screen.dart';

/// Background message handler for Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}

/// Entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Firebase Messaging for background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  await setupLocalNotifications();

  // Ensure Timezone data is initialized for scheduling notifications
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Request notification permissions
  await requestNotificationPermissions();

  // Schedule daily notification for the joke of the day
  await scheduleDailyNotification();
}

/// Requests notification permissions for Firebase Messaging
Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

/// Instance of Flutter Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Sets up local notifications
Future<void> setupLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

/// Schedules a daily notification for the joke of the day
Future<void> scheduleDailyNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'daily_reminder_channel',
    'Daily Reminders',
    channelDescription: 'Channel for daily joke reminders',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Daily Joke',
    'Time for your daily joke!',
    _nextInstanceOfTime(hour: 12, minute: 0),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_notification_channel',
        'Daily Notifications',
        channelDescription: 'Channel for daily notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}


tz.TZDateTime _nextInstanceOfTime({required int hour, required int minute}) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
  tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (context) => const MainScreen(),
        '/random-joke': (context) => const RandomJokeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
