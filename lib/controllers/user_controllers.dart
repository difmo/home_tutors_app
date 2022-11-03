import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserControllers {
  static User? currentUser = FirebaseAuth.instance.currentUser;

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllPosts(
      String stateName) {
    try {
      var collection = FirebaseFirestore.instance
          .collection('posts')
          .where('createdOn',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 7))))
          .where("state", isEqualTo: stateName)
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
}
