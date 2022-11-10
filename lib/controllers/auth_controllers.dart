import 'package:app/controllers/routes.dart';
import 'package:app/controllers/statics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthControllers {
  // static Future<SendOtpResponseModel> sendOtp(String mobile) async {
  //   try {
  //     SendOtpResponseModel response = SendOtpResponseModel();
  //     await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: mobile,
  //       timeout: const Duration(seconds: 120),
  //       verificationCompleted: (PhoneAuthCredential credential) async {},
  //       verificationFailed: (FirebaseAuthException e) {
  //         response.error = e.message;
  //       },
  //       codeSent: (String verificationId, int? resendToken) async {
  //         response.id = verificationId;
  //         response.token = resendToken;
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         response.id = verificationId;
  //       },
  //     );
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  static Future<User?> verifyOtp(
      {required String id, required String code}) async {
    try {
      final PhoneAuthCredential credential =
          PhoneAuthProvider.credential(verificationId: id, smsCode: code);
      final UserCredential response =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return response.user;
    } on FirebaseAuthException catch (error) {
      EasyLoading.dismiss();
      EasyLoading.showError(error.code);
      rethrow;
    }
  }

  // static Future<User?> register(
  //     {required String email, required String password}) async {
  //   try {
  //     final credential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     String? token = await FirebaseMessaging.instance.getToken();

  //     Map<String, dynamic> profilData = {
  //       'uid': credential.user?.uid,
  //       'name': "",
  //       'email': credential.user?.email,
  //       'status': 0,
  //       'phone': "",
  //       'photoUrl': "",
  //       'locality': "",
  //       'city': "",
  //       'state': "",
  //       'preferedClass': "",
  //       'preferedSubject': "",
  //       'preferedMode': "",
  //       'gender': "",
  //       'totalExp': "",
  //       'qualification': "",
  //       'idType': "",
  //       'idUrlFront': "",
  //       'idUrlBack': "",
  //       'wallet_balance': 0,
  //       'createdOn': FieldValue.serverTimestamp(),
  //       "fcm_token": token
  //     };
  //     await ProfileController.createProfile(profileBody: profilData);
  //     String? adminToken = await AdminControllers.getAdminToken();
  //     await AdminControllers.sendNotification(
  //         deviceToken: adminToken,
  //         title: "New registration",
  //         body: "check new registrations");
  //     return credential.user;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       Utils.toast("The password provided is too weak.");
  //       debugPrint('The password provided is too weak.');
  //     } else if (e.code == 'email-already-in-use') {
  //       Utils.toast("Account already exists for that email.");
  //       debugPrint('The account already exists for that email.');
  //     } else if (e.code == 'invalid-email') {
  //       Utils.toast("Invalid email");
  //       debugPrint('Invalid email');
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   return null;
  // }

  // static Future changePassword({required String email}) async {
  //   try {
  //     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       Utils.toast("User not found");
  //       debugPrint('No user found for that email.');
  //     } else if (e.code == 'invalid-email') {
  //       Utils.toast("Invalid email");
  //       debugPrint('Invalid email');
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  static String manageLogin() {
    switch (FirebaseAuth.instance.currentUser?.phoneNumber) {
      case null:
        return AppRoutes.onboarding;
      case adminPhone:
        return AppRoutes.adminHome;
      default:
        return AppRoutes.home;
    }
  }

  static bool isAdmin() {
    if (FirebaseAuth.instance.currentUser?.phoneNumber == adminPhone) {
      return true;
    } else {
      return false;
    }
  }
}

class SendOtpResponseModel {
  String? id;
  int? token;
  String? error;

  SendOtpResponseModel({this.id, this.token, this.error});
}
