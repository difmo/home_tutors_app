import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userApiProviders = Provider<UserControllers>((ref) {
  return UserControllers();
});

class UserControllers {
  static User? currentUser = FirebaseAuth.instance.currentUser;

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllPosts(
      String? stateName, int limit) {
    Stream<QuerySnapshot<Map<String, dynamic>>> collection;
    try {
      if (stateName == null) {
        collection = FirebaseFirestore.instance
            .collection('posts')
            .where('createdOn',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime.now().subtract(const Duration(days: 7))))
            .orderBy('createdOn', descending: true)
            .limit(limit)
            .snapshots();
      } else {
        collection = FirebaseFirestore.instance
            .collection('posts')
            .where('createdOn',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime.now().subtract(const Duration(days: 7))))
            .where("state", isEqualTo: stateName)
            .orderBy('createdOn', descending: true)
            .limit(limit)
            .snapshots();
      }

      return collection;
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
}
