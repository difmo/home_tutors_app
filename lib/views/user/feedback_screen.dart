import 'package:app/controllers/user_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/utils.dart';

class FeedbackScreen extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if (checkEmpty(value)) {
                    return "Invalid tilte";
                  } else {
                    return null;
                  }
                },
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: "Title", hintText: "Main Heading"),
                maxLength: 50,
              ),
              TextFormField(
                controller: descController,
                validator: (value) {
                  if (checkEmpty(value)) {
                    return "Invalid desc";
                  } else {
                    return null;
                  }
                },
                maxLength: 300,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: "Description", hintText: "More Details"),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                  onPressed: () {
                    formSubmitFunction(
                        formKey: _formKey,
                        submitFunction: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          Utils.loading();
                          Map<String, dynamic> postBody = {
                            "title": titleController.text,
                            "desc": descController.text,
                            "uid": user?.uid,
                            "phone": user?.phoneNumber,
                            "createdOn": FieldValue.serverTimestamp()
                          };
                          await UserControllers.submitFeedback(postBody);
                          EasyLoading.dismiss();
                          EasyLoading.showInfo("Feedback Submitted");
                          context.pop();
                        });
                  },
                  child: const Text("Submit")),
            ],
          ),
        ),
      )),
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
    );
  }
}
