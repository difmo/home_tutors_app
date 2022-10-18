import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Utils {
  static void toast(String text) {
    EasyLoading.showToast(text, toastPosition: EasyLoadingToastPosition.bottom);
  }

  static void loading({String? msg}) {
    EasyLoading.show(maskType: EasyLoadingMaskType.clear, status: msg);
  }
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
