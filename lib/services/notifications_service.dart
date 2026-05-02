import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/models/inspiration_item.dart';
import '../features/daily/daily_reflection_provider.dart';

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});

class NotificationsService {
  static const _dailyReminderBaseId = 2100;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _pluginAvailable = true;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } on MissingPluginException {
      // Fallback when timezone plugin channel is not yet registered.
      tz.setLocalLocation(tz.local);
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    try {
      await _plugin.initialize(initializationSettings);
      _pluginAvailable = true;
    } on MissingPluginException {
      _pluginAvailable = false;
      debugPrint(
        'Notifications plugin unavailable. Try full restart if reminders are needed.',
      );
    }
  }

  Future<bool> requestPermissions() async {
    if (!_pluginAvailable) {
      return false;
    }

    var granted = true;

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      granted = await androidImplementation.requestNotificationsPermission() ??
          granted;
    }

    if (iosImplementation != null) {
      granted = (await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          )) ??
          granted;
    }

    return granted;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    List<InspirationItem> items = const [],
  }) async {
    if (!_pluginAvailable) {
      return;
    }

    await cancelDailyReminder();

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final scheduledDate = _nextInstanceOfWeekdayTime(
        weekday: weekday,
        hour: hour,
        minute: minute,
      );
      final reminder = buildReminderCopy(
        date: scheduledDate,
        items: items,
      );

      try {
        await _plugin.zonedSchedule(
          _dailyReminderBaseId + weekday,
          reminder.title,
          reminder.body,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_faith_inspire',
              'Daily Inspiration',
              channelDescription: 'Daily reminder to revisit Faith Inspire.',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } on MissingPluginException {
        _pluginAvailable = false;
        return;
      }
    }
  }

  Future<void> cancelDailyReminder() async {
    if (!_pluginAvailable) {
      return;
    }

    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      try {
        await _plugin.cancel(_dailyReminderBaseId + weekday);
      } on MissingPluginException {
        _pluginAvailable = false;
        return;
      }
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
