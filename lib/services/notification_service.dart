import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/log.dart' as logger;

/// Handles a message that arrives while the app is terminated or backgrounded.
///
/// Must be a top-level function — Firebase spins up a separate isolate to run
/// it, so it cannot close over anything.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  logger.log.fine('Background push received: ${message.messageId}');
}

/// Push notifications for ride events (Milestone 4, §2).
///
/// Drivers get a push when a passenger books one of their rides. The message
/// itself is sent by the `onRideBooked` Cloud Function; this class is the
/// client half — it registers the device, keeps the token on the user's
/// record so the function knows where to send, and surfaces messages that
/// arrive while the app is open.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();

  /// Android needs a channel to show heads-up notifications on O and above.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tagalong_rides',
    'Ride updates',
    description: 'Notifications about your TagAlong rides',
    importance: Importance.high,
  );

  /// Called when the user taps a notification. Set by the app so it can route
  /// to the right screen.
  void Function(RemoteMessage message)? onNotificationTapped;

  bool _initialized = false;

  /// Sets up the channel, permissions, and message listeners. Safe to call
  /// more than once.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _messaging.requestPermission();

      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // A push that arrives while the app is in the foreground doesn't get
      // shown by the system, so we post it ourselves.
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);

      // Tapped from the system tray while the app was backgrounded.
      FirebaseMessaging.onMessageOpenedApp.listen((message) => onNotificationTapped?.call(message));

      // Tapped while the app was terminated — this is what launched us.
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        onNotificationTapped?.call(initialMessage);
      }
    } catch (error, stack) {
      // Push is a nice-to-have; never let it stop the app from starting.
      logger.log.warning('NotificationService - initialize failed: $error', error, stack);
    }
  }

  /// Stores this device's FCM token against [userId] so the Cloud Function can
  /// reach them, and keeps it current if Firebase rotates it.
  Future<void> registerDevice(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(userId, token);
      }
      _messaging.onTokenRefresh.listen((token) => _saveToken(userId, token));
    } catch (error) {
      logger.log.warning('NotificationService - could not register device: $error');
    }
  }

  /// Drops the token when the user signs out so they stop receiving pushes on
  /// a device that is no longer theirs.
  Future<void> unregisterDevice(String userId) async {
    try {
      await _databaseService.users.doc(userId).update({'fcm_token': null});
      await _messaging.deleteToken();
    } catch (error) {
      logger.log.warning('NotificationService - could not unregister device: $error');
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await _databaseService.users.doc(userId).update({'fcm_token': token});
      logger.log.fine('NotificationService - stored FCM token for $userId');
    } catch (error) {
      logger.log.warning('NotificationService - could not store FCM token: $error');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
