import 'dart:developer';
import 'dart:io';

import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/models/city_list_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final profileApiProviders = Provider<ProfileController>((ref) {
  return ProfileController();
});

class ProfileController {
  Future<CityListModel?> getCityList(String state) async {
    try {
      Map<String, String> params = {"country": "India", "state": state};
      var response = await http.get(
          Uri.https("countriesnow.space", "/api/v0.1/countries/state/cities/q",
              params),
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*',
          });

      if (response.statusCode == 200) {
        var data = cityListModelFromJson(response.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future createProfile() async {
    String? token = await FirebaseMessaging.instance.getToken();
    var user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> profilData = {
      'uid': user?.uid,
      'is_admin': false,
      'name': "",
      'email': "",
      'status': 0,
      "rating": 1,
      'phone': user?.phoneNumber,
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
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(profilData["uid"])
          .set(profilData);
    } catch (e) {
      rethrow;
    }
  }

  static Future updateProfile(
      {required Map<String, dynamic> profileBody, String? uidFromAdmin}) async {
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection("users");
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      await users.doc(uidFromAdmin ?? uid).update(profileBody);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> createTransaction({
    required Map<String, dynamic> postBody,
  }) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('transaction')
          .add(postBody);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  static Future updateTransaction({
    required String docId,
    required Map<String, dynamic> postBody,
  }) async {
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection("transaction");
      await users.doc(docId).update(postBody);
    } catch (e) {
      rethrow;
    }
  }

  static Future uploadImage(File image) async {
    String filePath = 'images/${image.path.split("/").last}';
    try {
      TaskSnapshot uploadTask =
          await FirebaseStorage.instance.ref(filePath).putFile(image);
      String? url = await uploadTask.ref.getDownloadURL();
      debugPrint("download url : $url");
      return url;
    } on FirebaseException catch (e) {
      log(e.code);
      // e.g, e.code == 'canceled'
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>?> fetchProfileData(String? uid) async {
    if (uid == null) {
      return null;
    } else {
      var collection = FirebaseFirestore.instance.collection('users');
      var docSnapshot = await collection.doc(uid).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        return data;
      } else {
        return null;
      }
    }
  }

  static Future createWalletHit(
      {required Map<String, dynamic> postBody}) async {
    try {
      await FirebaseFirestore.instance
          .collection('wallet_hits')
          .doc()
          .set(postBody);
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllTransactions(
      bool isAdmin, int limit, String status) {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      Stream<QuerySnapshot<Map<String, dynamic>>> collection;
      if (isAdmin) {
        if (status == "All") {
          collection = FirebaseFirestore.instance
              .collection('transaction')
              .limit(limit)
              .orderBy('createdOn', descending: true)
              .snapshots();
        } else {
          collection = FirebaseFirestore.instance
              .collection('transaction')
              .where("status", isEqualTo: status == "true" ? true : false)
              .limit(limit)
              .orderBy('createdOn', descending: true)
              .snapshots();
        }
      } else {
        collection = FirebaseFirestore.instance
            .collection('transaction')
            .where("uid", isEqualTo: auth.currentUser?.uid)
            .limit(limit)
            .orderBy('createdOn', descending: true)
            .snapshots();
      }

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Future logout(BuildContext context) async {
    Utils.loading(msg: 'Please wait');
    await FirebaseAuth.instance.signOut();
    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();
    EasyLoading.dismiss();
    Future.delayed(Duration.zero).then((value) {
      context.go(AppRoutes.onboarding);
    });
  }
}
