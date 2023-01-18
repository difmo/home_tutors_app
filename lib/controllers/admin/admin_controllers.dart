import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app/controllers/statics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/utils_model.dart';
import '../user_controllers.dart';
import '../utils.dart';

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

  static Future<int> lastPostId() async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection('posts')
          .limit(5)
          .orderBy('createdOn', descending: true)
          .get();
      return collection.docs.first["id"] ?? collection.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  static Future clearOldPosts() async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection('posts')
          .where('createdOn',
              isLessThan: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 7))))
          .get();
      for (var element in collection.docs) {
        log(element["createdOn"].toDate().toString());
        await element.reference.delete();
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  static Future clearDeclinedUsers() async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 2)
          .get();
      for (var element in collection.docs) {
        log(element["createdOn"].toDate().toString());
        await element.reference.delete();
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getUsersList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> collection = await FirebaseFirestore
          .instance
          .collection('users')
          .orderBy('createdOn', descending: true)
          .where("status", isEqualTo: 1)
          .get();
      var data = collection.docs;
      await generateUserExcel(data);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  static Future generateUserExcel(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> listData) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['active_users'];
    var cell = sheetObject.cell(CellIndex.indexByString("A1"));
    cell.value = 8; // Insert value to selected cell;
    for (int i = 0; i < listData.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByString(
          'A${i + 1}')); //i+1 means when the loop iterates every time it will write values in new row, e.g A1, A2, ...
      cell.value = listData[i].data()['name']; // Insert value to selected cell;
    }
    for (int i = 0; i < listData.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByString(
          'B${i + 1}')); //i+1 means when the loop iterates every time it will write values in new row, e.g A1, A2, ...
      cell.value =
          listData[i].data()['phone']; // Insert value to selected cell;
    }
    for (int i = 0; i < listData.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByString(
          'C${i + 1}')); //i+1 means when the loop iterates every time it will write values in new row, e.g A1, A2, ...
      cell.value =
          listData[i].data()['email']; // Insert value to selected cell;
    }
    for (int i = 0; i < listData.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByString(
          'D${i + 1}')); //i+1 means when the loop iterates every time it will write values in new row, e.g A1, A2, ...
      cell.value =
          listData[i].data()['createdOn']; // Insert value to selected cell;
    }
    final file = await _localFile;
    var tempFile = await file.writeAsBytes(excel.encode()!);
    Share.shareXFiles([
      XFile(tempFile.path, name: "active_users"),
    ], subject: "Download file", text: "List of active users");
    return file.writeAsBytes(excel.encode()!);
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/active_users.xlsx');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers(int limit,
      {required bool noFIlter,
      required String filterKey,
      required dynamic filterValue}) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> collection;
      if (noFIlter) {
        collection = FirebaseFirestore.instance
            .collection('users')
            .limit(limit)
            .orderBy('createdOn', descending: true)
            .snapshots();
      } else {
        collection = FirebaseFirestore.instance
            .collection('users')
            .limit(limit)
            .orderBy('createdOn', descending: true)
            .where(filterKey, isEqualTo: filterValue)
            .snapshots();
      }

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> searchUser(
      String searchValue) async {
    try {
      QuerySnapshot<Map<String, dynamic>> collection;
      if (isNumber(searchValue)) {
        collection = await FirebaseFirestore.instance
            .collection('users')
            .where("phone", isEqualTo: "+91$searchValue")
            .get();
      } else {
        collection = await FirebaseFirestore.instance
            .collection('users')
            .orderBy('name')
            .limit(50)
            .startAt([searchValue]).get();
      }

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllWalletHits() {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> collection;
      collection = FirebaseFirestore.instance
          .collection('wallet_hits')
          .orderBy('createdOn', descending: true)
          .snapshots();

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAmountOptions() {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> collection;
      collection = FirebaseFirestore.instance
          .collection('amount_options')
          .orderBy('createdOn', descending: true)
          .snapshots();

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  static Future editLead(
      {required Map<String, dynamic> data, String? docId}) async {
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection("posts");
      await users.doc(docId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future createLeads({
    required Map<String, dynamic> postBody,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc().set(postBody);
      String topic = "all";
      if (postBody["state"] != null) {
        topic = (postBody["state"] ?? "all").replaceAll(' ', '').toLowerCase();
      }
      await AdminControllers.sendNotification(
          deviceToken: "/topics/$topic",
          title: "New lead added for ${postBody["state"]}",
          body: "checkout new lead in ${postBody["city"]} city");
    } catch (e) {
      rethrow;
    }
  }

  static Future createAmountOption({
    required Map<String, dynamic> postBody,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('amount_options')
          .doc()
          .set(postBody);
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

  static Future deleteUser({
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future deleteAmountOption({
    required String id,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('amount_options')
          .doc(id)
          .delete();
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

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>?>> getMatchedUsers(
      Map<String, dynamic>? data) async {
    if (data?["location"] != null) {
      LessGetGeoPoint getLessGeoPoint = Utils.getGeoPoints(
          data: PostLocationFilterModel(
              geoPoint: data?["location"], radius: 10.0));
      var subjectCollection = await FirebaseFirestore.instance
          .collection('users')
          .where("location", isLessThan: getLessGeoPoint.great)
          .where("location", isGreaterThan: getLessGeoPoint.less)
          .limit(50)
          .get();

      // List<QueryDocumentSnapshot<Map<String, dynamic>>?> finalCollection = [];

      // for (var doc in subjectCollection.docs) {
      //   for (var doc2 in classCollection.docs) {
      //     if (!finalCollection.contains(doc)) {
      //       finalCollection.add(doc);
      //     }
      //   }
      // }
      return subjectCollection.docs;
    } else {
      return [];
    }
  }
}
