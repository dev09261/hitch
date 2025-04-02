import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hitch/main.dart';
import 'package:hitch/src/features/main_menu_page.dart';
import 'package:hitch/src/firebase_server_key/firebase_server_key_provider.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/services/app_icon_badger_service.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final notification = FlutterLocalNotificationsPlugin();
  static const String channelId = 'hitch-notification';
  static const String channelDesc = 'Hitch Notification';

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initializeFirebaseMessaging() async {
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // On iOS, this helps to take the user permissions
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  static void startNotificationListeners() {
    // listen for message and background message
    FirebaseMessaging.onMessage.listen((msg){
      debugPrint("Notification received");
      AppIconBadgerService.updateAppIconBadge();
      if(Platform.isAndroid){
        _firebaseMessageHandler(msg);
      }

    });
    FirebaseMessaging.onBackgroundMessage((msg){
      debugPrint("Notification received in background");
      AppIconBadgerService.updateAppIconBadge();
      return _firebaseMessageHandler(msg,);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessageHandler(RemoteMessage message) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    if (message.notification != null) {
      NotificationService.show(
        title: message.notification!.title,
        body: message.notification!.body,
      );
    }
  }

  static Future<void> startNotificationClickListeners() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _notificationClickHandler(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_notificationClickHandler);
  }

  static Future<String?> getToken() async {
    return await firebaseMessaging.getToken();
  }

  static Future<String?> notificationClickAction({required RemoteMessage message,}) async {
    try {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (ctx)=> const MainMenuPage(comingFromNotification: true,)));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<bool?> requestPermissions() async {
    if (Platform.isIOS) {
      bool? result = await notification
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result;
    }
    return null;
  }

  static Future<void> initializeLocalNotifications() async {
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('pickle_ball'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
      ),
    );

    await notification.initialize(initializationSettings);
  }

  static void show({String? title, String? body,}) async {
    bool isAllowed = true;

    if (isAllowed) {
      try {
        const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelDesc,
            icon: 'pickle_ball',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        await notification.show(
          0,
          title,
          body,
          notificationDetails,
        );
      } catch (e) {
        //
      }
    }
  }
  static Future<void> _notificationClickHandler(RemoteMessage message) async {
    bool hasCurrentUser = FirebaseAuth.instance.currentUser != null;
    if (hasCurrentUser) {
      NotificationService.notificationClickAction(message: message);
    }
  }

  static Future<void> sendNotification({required UserModel receiver, required UserModel sender, bool isAcceptHitch = false})async{

    String notificationTitle = 'Hitch Play Request';
    String notificationBody = 'You have received a new Hitch request from ${sender.userName}';
    if(isAcceptHitch){
      notificationTitle = 'Hitch Play Request Accepted';
      notificationBody = '${sender.userName} accepted your Hitch request';
    }
    String serverKey = await FirebaseServerKeyProvider.getServerKey();
    var dataUpdated = {
      "message":{
        "token": receiver.token,
        "notification":{
          "body": notificationBody,
          "title": notificationTitle
        }
      }
    };

    final String firebaseProjectAppID = dotenv.env['FIREBASE_PROJECT_ID']!;
    await http.post(Uri.parse('https://fcm.googleapis.com/v1/projects/$firebaseProjectAppID/messages:send'),
        body: jsonEncode(dataUpdated) ,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization' : 'Bearer $serverKey'
        }
    ).then((value){

      if (kDebugMode) {
        print("Notification sent response: ${value.body}");
      }
    }).onError((error, stackTrace){
      if (kDebugMode) {
        print(error);
      }
    });
  }
}