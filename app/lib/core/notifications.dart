import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';

/// Stable 31-bit notification id derived from a reminder UUID.
int notificationIdFor(String reminderId) {
  var hash = 0x811c9dc5;
  for (final unit in reminderId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// Local reminder notifications.
///
/// The app only targets Android. On other platforms (including the host used
/// by widget tests) every operation is a safe no-op.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _available = false;
  String? _pendingReminderId;
  void Function(String reminderId)? _onOpenReminder;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!isSupported) return;

    try {
      tz_data.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      try {
        tz.setLocalLocation(tz.getLocation(local.identifier));
      } catch (_) {
        // Keep the package default when the platform reports a zone that is
        // not present in the bundled tz database.
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleResponse,
      );
      _available = true;

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        _pendingReminderId = launch?.notificationResponse?.payload;
      }
    } catch (_) {
      // Notifications are best-effort; the rest of the app keeps working.
      _available = false;
    }
  }

  /// Registers the navigation callback once the router is ready.
  void setOpenReminderHandler(void Function(String reminderId) handler) {
    _onOpenReminder = handler;
    final pending = _pendingReminderId;
    if (pending != null && pending.isNotEmpty) {
      _pendingReminderId = null;
      handler(pending);
    }
  }

  /// Requests the Android 13+ notification permission. Returns `true` when
  /// notifications are available or no runtime prompt is needed.
  Future<bool> requestPermission() async {
    if (!_available) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? true;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_available) return;
    if (reminder.doneAt != null || !reminder.dueAt.isAfter(DateTime.now())) {
      await cancelReminder(reminder.id);
      return;
    }

    try {
      final note = reminder.note?.trim();
      await _plugin.zonedSchedule(
        id: notificationIdFor(reminder.id),
        title: reminder.title,
        body: note == null || note.isEmpty ? null : note,
        scheduledDate: tz.TZDateTime.from(reminder.dueAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'xzifra_reminders',
            'Reminders',
            channelDescription: 'Reminder alarms from Xzifra',
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        // Inexact on purpose: no exact-alarm permission is requested. Android
        // may deliver a few minutes late, which is acceptable for reminders.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.id,
      );
    } catch (_) {
      // The reminder is still saved even if the OS rejects the schedule.
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    if (!_available) return;
    try {
      await _plugin.cancel(id: notificationIdFor(reminderId));
    } catch (_) {
      // Nothing else to do if the OS channel is unavailable.
    }
  }

  /// Re-schedules every pending reminder after app start.
  Future<void> reschedulePending(AppDatabase database) async {
    if (!_available) return;
    try {
      final pending = await database.pendingReminders();
      for (final reminder in pending) {
        await scheduleReminder(reminder);
      }
    } catch (_) {
      // The in-app list remains the source of truth.
    }
  }

  void _handleResponse(NotificationResponse response) {
    final id = response.payload;
    if (id == null || id.isEmpty) return;
    final handler = _onOpenReminder;
    if (handler != null) {
      handler(id);
    } else {
      _pendingReminderId = id;
    }
  }
}
