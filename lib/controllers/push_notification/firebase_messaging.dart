import 'package:app/controllers/push_notification/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  static void showMessage() {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // firebaseMessaging.getToken().then((value) => `storeToken(value));
    // // print('fcm token ${fcm_token}');
    // // storeToken(fcm_token);

    firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        // final routeFromMessage = message.data['route'];
        // log("$routeFromMessage") ;
        // Navigator.of(context).pushNamed(routeFromMessage);
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
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  PushNotificationService.display(message);
}
