import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');
          
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      await _notifications.initialize(initializationSettings);

      // Setup channel for Android
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'debt_reminders',
          'Debt Reminders',
          description: 'Notifications for debt return dates',
          importance: Importance.max,
        );
        await androidPlugin.createNotificationChannel(channel);
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> scheduleDebtReminder({
    required int id,
    required String personName,
    required double amount,
    required String currency,
    required DateTime scheduledDate,
  }) async {
    try {
      // Request permission if not already granted
      await requestPermission();

      // Schedule for 9 AM on the return date
      final scheduledDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        9, 0, 0,
      );

      if (scheduledDateTime.isBefore(DateTime.now())) return;

      final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

      await _notifications.zonedSchedule(
        id,
        'Debt Reminder: $personName',
        'Today is the expected date to settle the debt of $currency $amount.',
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debt_reminders',
            'Debt Reminders',
            channelDescription: 'Notifications for debt return dates',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            icon: 'ic_notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Scheduled debt reminder for $personName at $tzDateTime');
    } catch (e) {
      print('Error scheduling debt reminder for $id: $e');
    }
  }

  static Future<void> cancelDebtReminder(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      print('Error cancelling reminder for $id: $e');
    }
  }
}
