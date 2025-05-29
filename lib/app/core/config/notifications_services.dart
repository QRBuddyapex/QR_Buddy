import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();



  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }


  void initLocalNotification(BuildContext context,RemoteMessage message)async {
    
      var androidInitialization =
          const AndroidInitializationSettings('@drawable/ic_notification');
      var iosInitialization =
          const DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: androidInitialization,
        iOS: iosInitialization,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
        
      );
      

  }


 
  void firebaseInit(){
    FirebaseMessaging.onMessage.listen((message){
      showNotifications(message);
      print('onMessage: ${message.data}');


      print(message.notification?.title.toString());
      print(message.notification?.body.toString());

    });
  }

    Future<void> showNotifications(RemoteMessage message)async{
        AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
          Random.secure().nextInt(1000000) as String,
          'qr_buddy',
          description: 'channelDescription',
          importance: Importance.max,
          playSound: true,
        );
        AndroidNotificationDetails androidNotificationDetails =  AndroidNotificationDetails(
          androidNotificationChannel.id.toString() , 
          androidNotificationChannel.name.toString() ,
          channelDescription: 'qr_buddy channel',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker'
          
        );
        var iosDetails = const DarwinNotificationDetails();
        NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosDetails,
        );

       

      Future.delayed(Duration.zero, () async {
         await flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          notificationDetails,
          payload: message.data['payload'],
        );



      
      });


   } 

  Future<String> getDeviceToken() async{
    String? token = await messaging.getToken();
    return token!;
  }
  void isTokenRefresh() async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    }
    );
  }
  




}