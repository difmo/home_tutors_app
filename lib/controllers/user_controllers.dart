import 'dart:developer';

import 'package:app/controllers/statics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final userApiProviders = Provider<UserControllers>((ref) {
  return UserControllers();
});

class PostLocationFilterModel {
  final GeoPoint geoPoint;
  double radius;

  PostLocationFilterModel({required this.geoPoint, required this.radius});
}

class UserControllers {
  static User? currentUser = FirebaseAuth.instance.currentUser;

  static Stream<QuerySnapshot<Map<String, dynamic>>>? fetchAllPosts(int limit) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? collection;
    try {
      collection = FirebaseFirestore.instance
          .collection('posts')
          .where('createdOn',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 7))))
          .orderBy('createdOn', descending: true)
          .limit(limit)
          .snapshots();

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<List<DocumentSnapshot<Object?>>> fetchNearbyPosts(
      {required PostLocationFilterModel filterData, required int limit}) {
    try {
      final geo = GeoFlutterFire();
      GeoFirePoint center = geo.point(
          latitude: filterData.geoPoint.latitude,
          longitude: filterData.geoPoint.longitude);
      var collectionReference = FirebaseFirestore.instance.collection('posts');
      var geoRef = geo.collection(collectionRef: collectionReference);

      Stream<List<DocumentSnapshot<Object?>>> stream = geoRef.within(
          center: center,
          radius: filterData.radius,
          field: "position",
          strictMode: true);
      return stream;
    } catch (e) {
      rethrow;
    }
  }

  static Future addUidIntoPost({
    required String postId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'users': FieldValue.arrayUnion([currentUser!.phoneNumber]),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future addToOrders(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc().set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore
          .instance
          .collection('orders')
          .where("uid", isEqualTo: currentUser!.uid)
          .get();
      return data.docs;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchPurchasedPost() {
    try {
      var collection = FirebaseFirestore.instance
          .collection('posts')
          .where("users", arrayContains: currentUser!.phoneNumber)
          .snapshots();

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAmountOptions() async {
    try {
      QuerySnapshot<Map<String, dynamic>> collection = await FirebaseFirestore
          .instance
          .collection('amount_options')
          .orderBy('createdOn', descending: true)
          .get();

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getPostData(String id) async {
    var collection = FirebaseFirestore.instance.collection('posts');
    var docSnapshot = await collection.doc(id).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      log("data: $data");
      return data;
    } else {
      return null;
    }
  }

  static Future<String?> getLocations(Uri uri,
      {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static Future<String?> getLocationDetails(Uri uri,
      {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchNotifications() async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection('notifications')
          .where('createdOn',
              isGreaterThan: Timestamp.fromDate(DateTime.now()
                  .subtract(const Duration(days: autoPostDeleteDateRange))))
          .orderBy('createdOn', descending: true)
          .get();

      return collection.docs;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      fetchNotificationsStream() {
    try {
      var collection = FirebaseFirestore.instance
          .collection('notifications')
          .where('createdOn',
              isGreaterThan: Timestamp.fromDate(DateTime.now()
                  .subtract(const Duration(days: autoPostDeleteDateRange))))
          .orderBy('createdOn', descending: true)
          .snapshots();

      return collection;
    } catch (e) {
      rethrow;
    }
  }
}
