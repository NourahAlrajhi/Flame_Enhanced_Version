import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService();
  final _LocalNotificationsService = FlutterLocalNotificationsPlugin();

  // firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A Background message just showed up :  ${message.messageId}');
}

  final BehaviorSubject<String?> onNotificationClick=BehaviorSubject();
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_stat_flame_01_svg');

  /*  IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );*/
    final InitializationSettings settings = InitializationSettings(
        android: androidInitializationSettings, /*iOS: iosInitializationSettings*/);
    await _LocalNotificationsService.initialize(
      settings,
      /*onSelectNotification: onSelectNotification*/
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel_name',
            channelDescription: 'description',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true);
  /*  const IOSNotificationDetails iosNotificationDetails =
        IOSNotificationDetails();*/
    return NotificationDetails(
        android: androidNotificationDetails, /*iOS: iosNotificationDetails*/);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    await _LocalNotificationsService.show(id, title, body, details);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('is $id');
  }

  void onSelectNotification(String? payload) {
    print('payload $payload');
    if(payload!=null && payload.isNotEmpty){
      onNotificationClick.add(payload );
    }
  }

  static void display(RemoteMessage message) async {
    try {
      print("In Notification method");
      // int id = DateTime.now().microsecondsSinceEpoch ~/1000000;
      Random random = new Random();
      int id = random.nextInt(1000);
      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails('channel_id', 'channel_name',
              channelDescription: 'description',
              importance: Importance.max,
              priority: Priority.max,
              playSound: true),
          /*iOS: IOSNotificationDetails()*/);
      print("my id is ${id.toString()}");
      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.title,
        notificationDetails,
      );
      
    } on Exception catch (e) {
      print('Error>>>$e');
    }
  }


}
