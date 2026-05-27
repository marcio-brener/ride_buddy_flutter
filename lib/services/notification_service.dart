import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String _channelId = 'end_of_day_reminder';
const int _notificationId = 100;
const String _prefEnabled = 'end_of_day_reminder_enabled';
const String _prefHour = 'end_of_day_reminder_hour';
const String _prefMinute = 'end_of_day_reminder_minute';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_bg_service_small');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await FlutterLocalNotificationsPlugin().initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            'Lembrete do Fim do Dia',
            description:
                'Lembrete diário para registrar sua jornada de trabalho.',
            importance: Importance.high,
          ),
        );

    await NotificationService()._rescheduleIfNeeded();
  }

  Future<bool> requestPermissions() async {
    final bool? androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final bool? iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  Future<void> scheduleEndOfDayReminder({
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, true);
    await prefs.setInt(_prefHour, hour);
    await prefs.setInt(_prefMinute, minute);

    await _plugin.zonedSchedule(
      _notificationId,
      'Ride Buddy — Fim do Dia',
      'Você registrou todas as suas jornadas de hoje?',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Lembrete do Fim do Dia',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_bg_service_small',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelEndOfDayReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, false);
    await _plugin.cancel(_notificationId);
  }

  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabled) ?? false;
  }

  Future<TimeOfDay> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return TimeOfDay(
      hour: prefs.getInt(_prefHour) ?? 20,
      minute: prefs.getInt(_prefMinute) ?? 0,
    );
  }

  Future<void> _rescheduleIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool(_prefEnabled) ?? false;
    if (!enabled) return;
    final int hour = prefs.getInt(_prefHour) ?? 20;
    final int minute = prefs.getInt(_prefMinute) ?? 0;
    await scheduleEndOfDayReminder(hour: hour, minute: minute);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
