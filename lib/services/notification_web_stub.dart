// Stub used on non-web platforms so that notification_service.dart compiles
// without pulling in dart:html.

Future<bool> requestWebPermission() async => true;

Future<void> scheduleWebReminder({
  required int hour,
  required int minute,
}) async {}

Future<void> cancelWebReminder() async {}
