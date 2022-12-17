import 'package:app/controllers/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/admin/admin_controllers.dart';
import '../../controllers/profile_controllers.dart';

class RoundedAlertBox extends HookConsumerWidget {
  const RoundedAlertBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reasonController = useTextEditingController();
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.all(20.0),
      title: const Text("Are you sure?"),
      content: const Text(
          "If you delete your account all of your wallet balance will be deleted and data can't be restored"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () async {
            Utils.loading();
            var data = await AdminControllers.deleteUser(
                userId: FirebaseAuth.instance.currentUser!.uid);
            if (data == 200) {
              Future.delayed(Duration.zero).then((value) async {
                await ProfileController.logout(context);
              });
            }
            EasyLoading.dismiss();
          },
          child: const Text(
            "Delete",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
