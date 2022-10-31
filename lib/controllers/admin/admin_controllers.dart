import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final adminApiProviders = Provider<AdminControllers>((ref) {
  return AdminControllers();
});

class AdminControllers {
  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllPosts() {
    try {
      var collection =
          FirebaseFirestore.instance.collection('posts').snapshots();
      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?>
      fetchAllUsers() async {
    try {
      var collection = FirebaseFirestore.instance.collection('users');
      var docSnapshot = await collection.get();
      if (docSnapshot.docs.isNotEmpty) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
            docSnapshot.docs;
        return data.reversed.toList();
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future createLeads({
    required Map<String, dynamic> postBody,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc().set(postBody);
    } catch (e) {
      rethrow;
    }
  }

  static Future deleteLead({
    required String postId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
