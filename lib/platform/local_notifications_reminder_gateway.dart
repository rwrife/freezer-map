import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezer_map/application/reminders.dart';
import 'package:freezer_map/domain/value_objects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final class LocalNotificationsReminderGateway
    implements ReminderNotificationGateway {
  LocalNotificationsReminderGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'freezer_reminders',
    'Inventory reminders',
    description: 'Local freezer planning reminders',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<ReminderTapEvent> _tapEvents =
      StreamController<ReminderTapEvent>.broadcast();

  Future<void>? _initialized;

  @override
  Future<void> initialize() {
    _initialized ??= _initializeOnce();
    return _initialized!;
  }

  @override
  Stream<ReminderTapEvent> tapEvents() => _tapEvents.stream;

  @override
  Future<ReminderPermissionStatus> permissionStatus() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.areNotificationsEnabled() ?? false;
      return granted
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.denied;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final permissions = await ios.checkPermissions();
      final granted =
          (permissions?.isEnabled ?? false) ||
          (permissions?.isProvisionalEnabled ?? false);
      return granted
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.denied;
    }

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (mac != null) {
      final permissions = await mac.checkPermissions();
      final granted =
          (permissions?.isEnabled ?? false) ||
          (permissions?.isProvisionalEnabled ?? false);
      return granted
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.denied;
    }

    return ReminderPermissionStatus.unknown;
  }

  @override
  Future<ReminderPermissionStatus> requestPermission() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      return granted
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.denied;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
      return granted
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.denied;
    }

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (mac != null) {
      final granted =
          await mac.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
      return granted
          ? ReminderPermissionStatus.granted
          : ReminderPermissionStatus.denied;
    }

    return ReminderPermissionStatus.denied;
  }

  @override
  Future<void> scheduleReminder(ReminderNotificationRequest request) async {
    await initialize();
    final schedule = tz.TZDateTime.from(request.scheduledForUtc, tz.UTC);

    await _plugin.zonedSchedule(
      _notificationId(request.reminderId),
      request.title,
      request.body,
      schedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'itemId': request.itemId.value,
        'reminderId': request.reminderId.value,
      }),
    );
  }

  @override
  Future<void> cancelReminder(ReminderId reminderId) async {
    await initialize();
    await _plugin.cancel(_notificationId(reminderId));
  }

  Future<void> _initializeOnce() async {
    tz.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _backgroundNotificationResponse,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_androidChannel);

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    final event = _eventFromPayload(launchResponse?.payload);
    if ((launchDetails?.didNotificationLaunchApp ?? false) && event != null) {
      _tapEvents.add(event);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final event = _eventFromPayload(response.payload);
    if (event == null) return;
    _tapEvents.add(event);
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationResponse(NotificationResponse response) {
    // Background taps are intentionally ignored unless the app is running.
  }

  ReminderTapEvent? _eventFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;
      final itemId = decoded['itemId'];
      final reminderId = decoded['reminderId'];
      if (itemId is! String || reminderId is! String) return null;
      return ReminderTapEvent(
        reminderId: ReminderId(reminderId),
        itemId: ItemId(itemId),
      );
    } catch (_) {
      return null;
    }
  }

  int _notificationId(ReminderId reminderId) {
    final hash = reminderId.value.hashCode & 0x7fffffff;
    return hash == 0 ? 1 : hash;
  }

  static const _androidChannelId = 'freezer_reminders';
  static const _androidChannelName = 'Inventory reminders';
  static const _androidChannelDescription = 'Local freezer planning reminders';
}
