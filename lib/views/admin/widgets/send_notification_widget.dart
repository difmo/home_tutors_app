import 'package:app/controllers/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/admin/admin_controllers.dart';
import '../../../controllers/statics.dart';
import '../../../controllers/utils.dart';

class SendNotificationWidget extends HookConsumerWidget {
  SendNotificationWidget({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedState = useState("all");
    final title = useTextEditingController();
    final message = useTextEditingController();

    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.all(20.0),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownSearch<String>(
              validator: (value) {
                if (checkEmpty(value)) {
                  return "Choose state";
                } else {
                  return null;
                }
              },
              selectedItem:
                  selectedState.value.isEmpty ? null : selectedState.value,
              popupProps: const PopupProps.menu(
                  showSelectedItems: true, showSearchBox: true),
              items: stateList,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Select state",
                  hintText: "choose state or search",
                ),
              ),
              onChanged: (value) {
                selectedState.value = value!;
              },
            ),
            TextField(
              controller: title,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: "Notification Title",
                  hintText: 'Notification title',
                  border: InputBorder.none),
              maxLength: 75,
            ),
            TextField(
              controller: message,
              decoration: const InputDecoration(
                  labelText: "Notification Message",
                  hintText: 'Short Notification content',
                  border: InputBorder.none),
              maxLines: 3,
              maxLength: 150,
            ),
          ],
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
                  String topic =
                      "/topics/${selectedState.value.replaceAll(' ', '').toLowerCase()}";
                  await AdminControllers.sendNotification(
                      deviceToken: topic,
                      title: title.text,
                      body: message.text,
                      navigation: AppRoutes.notifications);
                  Map<String, dynamic> postBody = {
                    "title": title.text,
                    "body": message.text,
                    "topic": topic,
                    "createdOn": FieldValue.serverTimestamp()
                  };
                  await AdminControllers.createNotification(postBody);
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
