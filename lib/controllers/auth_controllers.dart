import 'package:app/controllers/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthControllers {
  static Future<User?> register(
      {required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
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
  }

  static Future<User?> login(
      {required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
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
}
