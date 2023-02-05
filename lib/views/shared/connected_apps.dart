import 'dart:io';

import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/statics.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/admin/widgets/clear_data_confirm_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/profile_controllers.dart';
import '../../providers/admin_providers.dart';

class ConnectedAppsScreen extends StatefulHookConsumerWidget {
  const ConnectedAppsScreen({super.key});

  @override
  ConsumerState<ConnectedAppsScreen> createState() =>
      _ConnectedAppsScreenState();
}

class _ConnectedAppsScreenState extends ConsumerState<ConnectedAppsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    final connectedAppsProvider = ref.watch(connectedAppsFutureProvider);
    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final urlController = useTextEditingController();

    Future chooseFile() async {
      final XFile? profilePic = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 10,
          preferredCameraDevice: CameraDevice.front);
      if (profilePic != null) {
        setState(() {
          imageFile = File(profilePic.path);
        });
      }
    }

    return Scaffold(
      body: SafeArea(
          child: connectedAppsProvider.when(
        data: (data) {
          return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 0.5,
                );
              },
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                var item = data[index].data();
                return ListTile(
                  onTap: () {
                    openUrl(item["url"] ?? websiteUrl);
                  },
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      item["image"],
                    ),
                  ),
                  title: Text(
                    item["title"],
                  ),
                  subtitle: Text(item["desc"]),
                  trailing: AuthControllers.isAdmin()
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ClearDataWidget(
                                      onSubmit: () async {
                                        Utils.loading();
                                        await AdminControllers
                                            .deleteConnectedApp(data[index].id);
                                        EasyLoading.dismiss();
                                        ref.refresh(
                                            connectedAppsFutureProvider);
                                        context.pop();
                                      },
                                      title: "Are you sure?",
                                      desc: "You want to delete");
                                });
                          },
                          icon: const Icon(Icons.delete))
                      : null,
                );
              });
        },
        error: (error, stackTrace) {
          return const Text("Something went wrong");
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      )),
      appBar: AppBar(
        title: const Text("Connected Apps"),
        centerTitle: true,
        actions: AuthControllers.isAdmin()
            ? [
                TextButton.icon(
                    onPressed: () async {
                      await chooseFile();
                      if (!mounted) {
                        return;
                      }
                      showModalBottomSheet(
                          isScrollControlled: true,
                          useSafeArea: true,
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (BuildContext context, setState) {
                              return Container(
                                margin: const EdgeInsets.all(15.0),
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                    top: 20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              chooseFile();
                                            },
                                            child: imageFile == null
                                                ? const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                    size: 100,
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: Image.file(
                                                      imageFile!,
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                              child: TextFormField(
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
                                                labelText: "Title",
                                                hintText: "Main Heading"),
                                            maxLength: 50,
                                          ))
                                        ],
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
                                        decoration: const InputDecoration(
                                            labelText: "Description",
                                            hintText: "More Details"),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: urlController,
                                              validator: (value) {
                                                if (checkEmpty(value)) {
                                                  return "Invalid URL";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              decoration: const InputDecoration(
                                                  labelText: "URL",
                                                  hintText: "On Tap Link"),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          ElevatedButton(
                                              onPressed: () {
                                                if (imageFile == null) {
                                                  chooseFile();
                                                } else {
                                                  formSubmitFunction(
                                                      formKey: _formKey,
                                                      submitFunction: () async {
                                                        Utils.loading();
                                                        String? imageUrl =
                                                            await ProfileController
                                                                .uploadImage(
                                                                    imageFile!);
                                                        Map<String, dynamic>
                                                            postBody = {
                                                          "image": imageUrl,
                                                          "title":
                                                              titleController
                                                                  .text,
                                                          "desc": descController
                                                              .text,
                                                          "url": urlController
                                                              .text,
                                                          "createdOn": FieldValue
                                                              .serverTimestamp()
                                                        };
                                                        await AdminControllers
                                                            .addConnectedApp(
                                                                postBody);
                                                        EasyLoading.dismiss();
                                                        ref.refresh(
                                                            connectedAppsFutureProvider);
                                                        context.pop();
                                                      });
                                                }
                                              },
                                              child: const Text("Submit")),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0),
                                    ],
                                  ),
                                ),
                              );
                            });
                          }).whenComplete(() {
                        titleController.clear();
                        descController.clear();
                        setState(() {
                          imageFile = null;
                        });
                      });
                    },
                    label: const Text("Add"),
                    icon: const Icon(Icons.add))
              ]
            : null,
      ),
    );
  }
}
