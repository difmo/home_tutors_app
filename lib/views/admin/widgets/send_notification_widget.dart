import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/admin/admin_controllers.dart';
import '../../../controllers/utils.dart';

class SendNotificationWidget extends HookConsumerWidget {
  SendNotificationWidget({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = useTextEditingController();
    final message = useTextEditingController();

    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.all(20.0),
      title: const Text("Send notification to all user"),
      content: SizedBox(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: "Title",
                    hintText: 'Notification title',
                    border: InputBorder.none),
                maxLength: 50,
              ),
              TextField(
                controller: message,
                decoration: const InputDecoration(
                    labelText: "Message",
                    hintText: 'Short Notification content',
                    border: InputBorder.none),
                maxLines: 3,
                maxLength: 100,
              ),
            ],
          ),
        ),
      ),
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
            formSubmitFunction(
                formKey: _formKey,
                submitFunction: () async {
                  Utils.loading();
                  await AdminControllers.sendNotification(
                      deviceToken: "/topics/all",
                      title: title.text,
                      body: message.text);
                  EasyLoading.dismiss();
                  Navigator.pop(context);
                });
          },
          child: const Text(
            "Send",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
