import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // tit, // description
    importance: Importance.high,
    playSound: true);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

firebaseInitialization() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  var token = await FirebaseMessaging.instance.getToken();
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
  return token;
}

firebaseOnMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      var notificationDetails = NotificationDetails(
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
          notification.title, notification.body, notificationDetails);
      // var count = NotificationCount().count += 1;
      // setNotificationCount((count + 1).toString());
    }
  });
}

// firebaseonMessageOpenedApp(context) {
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     String notificationId = message.data['NotificationId'];
//     navigateTo(
//         context: context,
//         screen: NotificationScreen(
//           notificationId: int.parse(notificationId),
//         ));
//   });
// }