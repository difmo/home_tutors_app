import 'dart:convert';
import 'dart:developer';

import 'package:app/controllers/statics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final adminApiProviders = Provider<AdminControllers>((ref) {
  return AdminControllers();
});

class AdminControllers {
  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllPosts(int limit) {
    try {
      var collection = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdOn', descending: true)
          .limit(limit)
          .snapshots();
      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers(
      int? status) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> collection;
      if (status == 10) {
        collection = FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdOn', descending: true)
            .snapshots();
      } else {
        collection = FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdOn', descending: true)
            .where("status", isEqualTo: status)
            .snapshots();
      }

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Future createLeads({
    required Map<String, dynamic> postBody,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc().set(postBody);
      await AdminControllers.sendNotification(
          deviceToken: "/topics/all",
          title: "New lead added for ${postBody["state"]}",
          body: "checkout new lead in ${postBody["city"]} city");
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

  static Future deletePost({
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendNotification(
      {required String deviceToken,
      required String title,
      required String body}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';

    // String toParams = "/topics/$uid";
    Map data = {
      "notification": {
        "body": body,
        "title": title,
      },
      "priority": "high",
      "data": {},
      "to": deviceToken
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAA5mx_f9E:APA91bHRs7Z1xzDjqL5jDa62dEaCWK9JBy8VrHHl9Qw3_IWzGGlNFp3Yle2r3UHM00tfUB7-KIec-MlcI4suJwJ_qvN4ZRKkzeugF57yuAIxePism3ORwq9p6D-KV0sGFyFXG8aLdf2f'
    };
    var url = Uri.parse(postUrl);

    final response = await http.post(url,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      log("sent notification with data: ${response.body}");
      log("true");
    } else {
      log("failed notification with data: ${response.body}");

      log("false");
    }
  }

  static Future<String> getAdminToken() async {
    var adminData = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: adminPhone)
        .get();
    return adminData.docs.first["fcm_token"];
  }

  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> fetchProfileData(
      String mobile) async {
    var collection = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: mobile)
        .get();
    if (collection.docs.isNotEmpty) {
      QueryDocumentSnapshot<Map<String, dynamic>> data = collection.docs.first;
      return data;
    } else {
      return null;
    }
  }
}
