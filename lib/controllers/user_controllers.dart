import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserControllers {
  static String? uid = FirebaseAuth.instance.currentUser?.uid;

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllPosts(
      String cityName) {
    try {
      var collection = FirebaseFirestore.instance
          .collection('posts')
          .where('createdOn',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 10))))
          .where("city", isEqualTo: cityName)
          .snapshots();

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
        'uid': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchPurchasedPost() {
    try {
      var collection = FirebaseFirestore.instance
          .collection('posts')
          .where("uid", arrayContains: uid)
          .snapshots();

      return collection;
    } catch (e) {
      rethrow;
    }
  }
}
