import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Utils {
  static void toast(String text) {
    EasyLoading.showToast(text, toastPosition: EasyLoadingToastPosition.bottom);
  }

  static void loading() {
    EasyLoading.show(maskType: EasyLoadingMaskType.clear);
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
