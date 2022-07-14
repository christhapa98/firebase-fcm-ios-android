import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) async {});

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // tit, // description
    importance: Importance.high,
    playSound: true);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAmkdDbSOsY4nefqcpOWV3UmFuiI7FL8M4",
            appId: "1:754671053131:ios:d6e9537387558aba1460ce",
            messagingSenderId: "754671053131",
            projectId: "fir-ios-test-c64eb"));
  } else {
    await Firebase.initializeApp();
  }
}

firebaseInitialization() async {
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAmkdDbSOsY4nefqcpOWV3UmFuiI7FL8M4",
            appId: "1:754671053131:ios:d6e9537387558aba1460ce",
            messagingSenderId: "754671053131",
            projectId: "fir-ios-test-c64eb"));
    _requestPermissions();
  } else {
    await Firebase.initializeApp();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  String? token = await FirebaseMessaging.instance.getToken();
  print(token);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  log('success');
}

firebaseOnMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    var notificationDetails = NotificationDetails(
      iOS: const IOSNotificationDetails(badgeNumber: 2),
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        enableVibration: true,
        importance: Importance.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    );
    flutterLocalNotificationsPlugin.show(notification.hashCode,
        notification!.title, notification.body, notificationDetails);
  });
}

void _requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

firebaseonMessageOpenedApp(context) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log('opened');
  });
}
