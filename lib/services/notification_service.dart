import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');
          
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      await _notifications.initialize(initializationSettings);

      // Request permissions for Android 13+
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  static Future<void> scheduleDebtReminder({
    required String id,
    required String personName,
    required double amount,
    required String currency,
    required DateTime scheduledDate,
  }) async {
    // Schedule for 7 AM on the return date
    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      7, 0, 0,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id.hashCode,
      'Debt Reminder: $personName',
      'Today is the expected date to settle the debt of $currency $amount.',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
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
  }

  static Future<void> cancelReminder(String id) async {
    await _notifications.cancel(id.hashCode);
  }
}
