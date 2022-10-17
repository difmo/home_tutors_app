import 'package:app/models/city_list_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future updateProfile({
    required String name,
    required String phone,
    required String locality,
    required String city,
    required String state,
    required String preferedClass,
    required String preferedSubject,
    required String preferedMode,
    required String gender,
    required String totalExp,
    required String qualification,
    required String idType,
    required String idUrlFront,
    required String idUrlBack,
    required String photoUrl,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;

    FirebaseFirestore.instance.collection('teachers').doc().set({
      'uid': user?.uid,
      'name': name,
      'email': user?.email,
      'isEmailVerified': user?.emailVerified, // will also be false
      'phone': phone,
      'photoUrl': user?.photoURL, // will always be null
      'locality': locality,
      'city': city,
      'state': state,
      'preferedClass': preferedClass,
      'preferedSubject': preferedSubject,
      'preferedMode': preferedMode,
      'gender': gender,
      'totalExp': totalExp,
      'qualification': qualification,
      'idType': idType,
      'idUrlFront': idUrlFront,
      'idUrlBack': idUrlBack
    });
  }
}
