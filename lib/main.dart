import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './widgets/webview.dart';
import '/firebase_options.dart'; // this file is generated by "flutterfire config" command

final navigatorKey = GlobalKey<NavigatorState>();

Future<String> _getId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? '';
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else {
    return 'Unknown';
  }
}

Future<PermissionStatus> requestNotificationPermissions() async {
  Future<PermissionStatus> permissionStatus =
      NotificationPermissions.getNotificationPermissionStatus();

  return permissionStatus;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'smily',
  );

  if (Platform.isAndroid) {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'smily', 'Smily',
        importance: Importance.high, priority: Priority.high);

    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, platformChannelSpecifics);
    }
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
  ]);

  String initialUrl = '';

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'smily',
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.setAutoInitEnabled(true);

  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  String? firebaseToken;
  try {
    firebaseToken = await messaging.getToken();
  } catch (error) {
    print('Failed to get FCMToken: $error');
  }

  final deviceUid = await _getId();

  final bool notificationsEnabled =
      (await requestNotificationPermissions()) == PermissionStatus.granted;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp(
      firebaseToken: firebaseToken ?? '',
      deviceUid: deviceUid,
      initialUrl: initialUrl,
      notificationsEnabled: notificationsEnabled));
}

class MyApp extends StatefulWidget {
  final String initialUrl, deviceUid, firebaseToken;
  final bool notificationsEnabled;

  const MyApp(
      {super.key,
      required this.initialUrl,
      required this.deviceUid,
      required this.firebaseToken,
      required this.notificationsEnabled});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String initialUrl = '';

  void handleMessage(RemoteMessage message) {
    if (Platform.isAndroid) {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'smily', 'Smily',
          importance: Importance.high, priority: Priority.high);

      const platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(0, message.notification!.title,
            message.notification!.body, platformChannelSpecifics);
      }
    }
  }

  void handleMessageOpened(RemoteMessage message) {
    try {
      if (message.data['click_action_link'] != null &&
          message.data['click_action_link'].isNotEmpty) {
        setState(() {
          initialUrl = message.data['click_action_link'];
        });
      } else {}
    } catch (e) {
      print('Error handling background message: $e');
      print(message);
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      try {
        if (initialMessage.data['click_action_link'] != null &&
            initialMessage.data['click_action_link'].isNotEmpty) {
          setState(() {
            initialUrl = initialMessage.data['click_action_link'];
          });
        } else {}
      } catch (e) {
        print('Error handling background initialMessage: $e');
        print(initialMessage);
      }
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpened);
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpened);
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smily',
      theme: ThemeData(
        fontFamily: 'Opensans',
      ),
      home: SmilyWebView(
          initialUrl: initialUrl,
          deviceUid: widget.deviceUid,
          firebaseToken: widget.firebaseToken,
          notificationsEnabled: widget.notificationsEnabled),
      navigatorKey: navigatorKey,
    );
  }
}
