// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

late SharedPreferences localStorage;

/// Global variables
/// * [GlobalKey<NavigatorState>]
class GlobalVariable {
  /// This global key is used in material app for navigation through firebase notifications.
  /// [navState] usage can be found in [notification_notifier.dart] file.
  static final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();
}

class Utils {
  static void toast(String text) {
    EasyLoading.showToast(text, toastPosition: EasyLoadingToastPosition.bottom);
  }

  static void loading({String? msg}) {
    EasyLoading.show(maskType: EasyLoadingMaskType.clear, status: msg);
  }

  // static LessGetGeoPoint getGeoPoints({required PostLocationFilterModel data}) {
  //   double lat = 0.0144927536231884;
  //   double lon = 0.0181818181818182;
  //   double distance = 11;
  //   double lowerLat = data.geoPoint.latitude - (lat * distance);
  //   double lowerLon = data.geoPoint.longitude - (lon * distance);
  //
  //   double greaterLat = data.geoPoint.latitude + (lat * distance);
  //   double greaterLon = data.geoPoint.longitude + (lon * distance);
  //
  //   GeoPoint lesserGeopoint = GeoPoint(lowerLat, lowerLon);
  //   GeoPoint greaterGeopoint = GeoPoint(greaterLat, greaterLon);
  //   final LessGetGeoPoint getLessGeoPoint =
  //       LessGetGeoPoint(lesserGeopoint, greaterGeopoint);
  //   return getLessGeoPoint;
  // }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

void formSubmitFunction(
    {required GlobalKey<FormState> formKey,
    required Function() submitFunction}) {
  // final _formKey = GlobalKey<FormState>();
  final isValid = formKey.currentState!.validate();
  if (!isValid) {
    return;
  } else {
    submitFunction();
  }
  formKey.currentState!.save();
}

bool checkEmpty(mixedVar) {
  //print('checkEmpty in 1');
  if (mixedVar is List || mixedVar is Map) {
    if (mixedVar.isEmpty) {
      return true;
    }
  } else {
    //print('checkEmpty in 2');
    var undef;
    var undefined;
    var i;
    var emptyValues = [
      undef,
      null,
      'null',
      'Null',
      'NULL',
      false,
      0,
      '',
      '0',
      '0.00',
      '0.0',
      'empty',
      undefined,
      'undefined'
    ];
    var len = emptyValues.length;
    if (mixedVar is String) {
      mixedVar = mixedVar.trim();
    }

    for (i = 0; i < len; i++) {
      if (mixedVar == emptyValues[i]) {
        return true;
      }
    }
  }
  return false;
}

final DateFormat formatWithMonthName = DateFormat.yMMMd();
final DateFormat formatWithMonthNameTime = DateFormat.yMMMd().add_jm();

final List<TextInputFormatter> numberOnlyInput = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly
];

Future<void> openUrl(String url) async {
  if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

const String adminContactMail = "tlr@viptutors.in";

bool isNumber(String? s) {
  if (s == null) {
    return false;
  }
  if (s.length < 10) {
    return false;
  }
  return double.tryParse(s) != null;
}
