// Web-only implementation of end-of-day reminder notifications.
// Uses the browser Notification API + a Dart Timer.
// Note: the Timer is cleared if the user closes or refreshes the tab.
// On the next page load, NotificationService.initialize() re-schedules it
// automatically (via _rescheduleIfNeeded).

// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Timer? _webReminderTimer;

Future<bool> requestWebPermission() async {
  final String permission = await html.Notification.requestPermission();
  return permission == 'granted';
}

Future<void> scheduleWebReminder({
  required int hour,
  required int minute,
}) async {
  _webReminderTimer?.cancel();

  final now = DateTime.now();
  var target = DateTime(now.year, now.month, now.day, hour, minute);
  if (!target.isAfter(now)) {
    target = target.add(const Duration(days: 1));
  }

  _webReminderTimer = Timer(target.difference(now), () {
    _showWebNotification();
    // Re-schedule for the next day.
    scheduleWebReminder(hour: hour, minute: minute);
  });
}

Future<void> cancelWebReminder() async {
  _webReminderTimer?.cancel();
  _webReminderTimer = null;
}

void _showWebNotification() {
  if (html.Notification.permission == 'granted') {
    html.Notification(
      'Ride Buddy — Fim do Dia',
      body: 'Você registrou todas as suas jornadas de hoje?',
      icon: '/favicon.png',
    );
  }
}
