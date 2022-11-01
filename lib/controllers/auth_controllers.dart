import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/statics.dart';
import 'package:app/controllers/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'profile_controllers.dart';

class AuthControllers {
  static Future<User?> register(
      {required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? token = await FirebaseMessaging.instance.getToken();

      Map<String, dynamic> profilData = {
        'uid': credential.user?.uid,
        'name': "",
        'email': credential.user?.email,
        'status': 0,
        'phone': "",
        'photoUrl': "",
        'locality': "",
        'city': "",
        'state': "",
        'preferedClass': "",
        'preferedSubject': "",
        'preferedMode': "",
        'gender': "",
        'totalExp': "",
        'qualification': "",
        'idType': "",
        'idUrlFront': "",
        'idUrlBack': "",
        'wallet_balance': 0,
        'createdOn': FieldValue.serverTimestamp(),
        "fcm_token": token
      };
      await ProfileController.createProfile(profileBody: profilData);
      String? adminToken = await AdminControllers.getAdminToken();
      await AdminControllers.sendNotification(
          deviceToken: adminToken,
          title: "New registration",
          body: "check new registrations");
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Utils.toast("The password provided is too weak.");
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Utils.toast("Account already exists for that email.");
        debugPrint('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        Utils.toast("Invalid email");
        debugPrint('Invalid email');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<User?> login(
      {required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String? token = await FirebaseMessaging.instance.getToken();
      await ProfileController.updateProfile(profileBody: {"fcm_token": token});
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.toast("User not found");
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Utils.toast("Incorrect password");
        debugPrint('Wrong password provided for that user.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future changePassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.toast("User not found");
        debugPrint('No user found for that email.');
      } else if (e.code == 'invalid-email') {
        Utils.toast("Invalid email");
        debugPrint('Invalid email');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static String manageLogin() {
    switch (FirebaseAuth.instance.currentUser?.email) {
      case null:
        return AppRoutes.onboarding;
      case adminEmail:
        return AppRoutes.adminHome;
      default:
        switch (FirebaseAuth.instance.currentUser?.emailVerified) {
          case true:
            return AppRoutes.home;
          default:
            return AppRoutes.emailVerification;
        }
    }
  }

  static bool isAdmin() {
    if (FirebaseAuth.instance.currentUser?.email == adminEmail) {
      return true;
    } else {
      return false;
    }
  }
}
