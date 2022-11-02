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
      await AdminControllers.sendNotification(
          deviceToken: "/topics/all",
          title: "New lead added",
          body: "checkout new lead in your city");
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
}
