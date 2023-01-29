import 'dart:developer';

import 'package:app/controllers/push_notification/push_notification.dart';
import 'package:app/controllers/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import '../utils.dart';

class Messaging {
  static void showMessage() {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // firebaseMessaging.getToken().then((value) => `storeToken(value));
    // // print('fcm token ${fcm_token}');
    // // storeToken(fcm_token);

    firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        if (message.data["navigation"] == AppRoutes.notifications) {
          GlobalVariable.navState.currentContext
              ?.go(message.data["navigation"]);
        }
      }
    });

    /// forground work
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      PushNotificationService.display(message!);
    });

    // When the app is in background but open and user taps
    // on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      PushNotificationService.display(message);
      log(message.data.toString());
      if (message.data["navigation"] == AppRoutes.notifications) {
        GlobalVariable.navState.currentContext?.go(message.data["navigation"]);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  PushNotificationService.display(message);
}
