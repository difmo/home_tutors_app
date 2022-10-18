import 'dart:io';

import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/statics.dart';

// ignore: must_be_immutable
class TeacherProfileScreen extends HookConsumerWidget {
  TeacherProfileScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;

  File? profilePicFile;
  File? idFront;
  File? idBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reBuild = useState(false);
    final firstLoad = useState(false);

    final nameController = useTextEditingController();
    final numberController = useTextEditingController();
    final localityController = useTextEditingController();
    final qualiController = useTextEditingController();

    final profilePicUrl = useState("");
    final idFrontPicUrl = useState("");
    final idBackPicUrl = useState("");

    final selectedState = useState("");
    final selectedCity = useState("");
    final selectedClass = useState("");
    final selectedSubject = useState("");

    final selectedExp = useState("");
    final selectedIdType = useState("");

    final selectedMode = useState("");
    final selectedGender = useState("");

    return Scaffold(
      body: SafeArea(
          child: ref.watch(profileDataProvider).when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(error.toString()),
          );
        },
        data: (data) {
          if (!firstLoad.value) {
            nameController.text = data?["name"];
            profilePicUrl.value = data?["photoUrl"];
            idFrontPicUrl.value = data?["idUrlFront"];
            idBackPicUrl.value = data?["idUrlBack"];
            numberController.text = data?["phone"];
            localityController.text = data?["locality"];
            qualiController.text = data?["qualification"];
            selectedGender.value = data?["gender"];
            selectedState.value = data?["state"];
            selectedCity.value = data?["city"];
            selectedClass.value = data?["preferedClass"];
            selectedSubject.value = data?["preferedSubject"];
            selectedExp.value = data?["totalExp"];
            selectedIdType.value = data?["idType"];
            selectedMode.value = data?["preferedMode"];
            firstLoad.value = true;
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () async {
                              final XFile? profilePic = await _picker.pickImage(
                                  source: ImageSource.camera, imageQuality: 10);
                              if (profilePic != null) {
                                profilePicFile = File(profilePic.path);
                                reBuild.value = !reBuild.value;
                              }
                            },
                            child: profilePicFile == null
                                ? profilePicUrl.value.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage:
                                            NetworkImage(profilePicUrl.value))
                                    : const CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage: AssetImage(
                                            'assets/placeholder_user.jpeg'))
                                : CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage: FileImage(profilePicFile!),
                                  )),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.length < 3) {
                                  return "Enter a valid name";
                                } else {
                                  return null;
                                }
                              },
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              maxLength: 50,
                              decoration: const InputDecoration(
                                hintText: "Ex: John Doe",
                                label: Text('Full name'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      'Personal details:',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Select your gender";
                        } else {
                          return null;
                        }
                      },
                      selectedItem: selectedGender.value.isEmpty
                          ? null
                          : selectedGender.value,
                      popupProps:
                          const PopupProps.menu(showSelectedItems: true),
                      items: const ["Male", "Female", "Others"],
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Gender",
                          hintText: "Choose Gender",
                        ),
                      ),
                      onChanged: (value) {
                        selectedGender.value = value!;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      validator: (value) {
                        if (value!.length < 10) {
                          return "Enter valid number";
                        } else {
                          return null;
                        }
                      },
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        hintText: "10 digit mobile number",
                        label: Text('Phone number'),
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.length < 2) {
                          return "Enter valid locality";
                        } else {
                          return null;
                        }
                      },
                      controller: localityController,
                      keyboardType: TextInputType.streetAddress,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        hintText: "Nearby or street name",
                        label: Text('Locality'),
                      ),
                    ),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Choose state";
                        } else {
                          return null;
                        }
                      },
                      selectedItem: selectedState.value.isEmpty
                          ? null
                          : selectedState.value,
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
                    const SizedBox(height: 10.0),
                    if (selectedState.value.isNotEmpty)
                      ref.watch(cityListProvider(selectedState.value)).when(
                        data: (data) {
                          return data != null
                              ? DropdownSearch<String>(
                                  validator: (value) {
                                    if (checkEmpty(value)) {
                                      return "Choose city";
                                    } else {
                                      return null;
                                    }
                                  },
                                  selectedItem: selectedCity.value.isEmpty
                                      ? null
                                      : selectedCity.value,
                                  popupProps: const PopupProps.menu(
                                      showSelectedItems: true,
                                      showSearchBox: true),
                                  items: data.data!,
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "Select city",
                                      hintText: "choose city or search",
                                    ),
                                  ),
                                  onChanged: (value) {
                                    selectedCity.value = value!;
                                  },
                                )
                              : const Text('No city found');
                        },
                        loading: () {
                          return const LinearProgressIndicator();
                        },
                        error: (error, stackTrace) {
                          return Text(error.toString());
                        },
                      ),
                    const SizedBox(height: 30.0),
                    Text(
                      'Class Preference:',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Choose prefered class";
                        } else {
                          return null;
                        }
                      },
                      selectedItem: selectedClass.value.isEmpty
                          ? null
                          : selectedClass.value,
                      popupProps:
                          const PopupProps.menu(showSelectedItems: true),
                      items: preferredClassList,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Prefered class",
                          hintText: "Ex: xi/xii",
                        ),
                      ),
                      onChanged: (value) {
                        selectedClass.value = value!;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Choose prefered mode";
                        } else {
                          return null;
                        }
                      },
                      selectedItem: selectedMode.value.isEmpty
                          ? null
                          : selectedMode.value,
                      popupProps:
                          const PopupProps.menu(showSelectedItems: true),
                      items: const ["Online", "Offline", "Any"],
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Prefered Mode",
                          hintText: "Online/offline/Any",
                        ),
                      ),
                      onChanged: (value) {
                        selectedMode.value = value!;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Choose prefered subject";
                        } else {
                          return null;
                        }
                      },
                      selectedItem: selectedSubject.value.isEmpty
                          ? null
                          : selectedSubject.value,
                      popupProps: const PopupProps.menu(
                          showSelectedItems: true, showSearchBox: true),
                      items: subjectList,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Prefered Subject",
                          hintText: "Arts/Science/Commerce",
                        ),
                      ),
                      onChanged: (value) {
                        selectedSubject.value = value!;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      'Qualifications:',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Select total experience ";
                        } else {
                          return null;
                        }
                      },
                      selectedItem:
                          selectedExp.value.isEmpty ? null : selectedExp.value,
                      popupProps:
                          const PopupProps.menu(showSelectedItems: true),
                      items:
                          List<String>.generate(30, (i) => (i + 1).toString()),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Total Experience",
                          hintText: "10 years or any other",
                        ),
                      ),
                      onChanged: (value) {
                        selectedExp.value = value!;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      validator: (value) {
                        if (value!.length < 2) {
                          return "Enter valid Qualification";
                        } else {
                          return null;
                        }
                      },
                      controller: qualiController,
                      keyboardType: TextInputType.text,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        hintText: "B.A/ M-TECH",
                        label: Text('Qualification'),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      'Documents:',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Select ID type";
                        } else {
                          return null;
                        }
                      },
                      selectedItem: selectedIdType.value.isEmpty
                          ? null
                          : selectedIdType.value,
                      popupProps:
                          const PopupProps.menu(showSelectedItems: true),
                      items: const ["Aadhar Card", "Voter Card", "Passport"],
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "ID proof type",
                          hintText: "10 years or any other",
                        ),
                      ),
                      onChanged: (value) {
                        selectedIdType.value = value!;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            final XFile? idFrontPic = await _picker.pickImage(
                                source: ImageSource.camera, imageQuality: 10);
                            if (idFrontPic != null) {
                              idFront = File(idFrontPic.path);
                              reBuild.value = !reBuild.value;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10.0)),
                            margin: const EdgeInsets.all(5.0),
                            height: 100,
                            child: idFront == null
                                ? profilePicUrl.value.isNotEmpty
                                    ? Image.network(idFrontPicUrl.value,
                                        fit: BoxFit.cover)
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text('Front side'),
                                          SizedBox(height: 5.0),
                                          Icon(Icons.image, size: 50.0),
                                        ],
                                      )
                                : Image.file(
                                    idFront!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        )),
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            final XFile? idBackPic = await _picker.pickImage(
                                source: ImageSource.camera, imageQuality: 10);
                            if (idBackPic != null) {
                              idBack = File(idBackPic.path);
                              reBuild.value = !reBuild.value;
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10.0)),
                            margin: const EdgeInsets.all(5.0),
                            height: 100,
                            child: idBack == null
                                ? profilePicUrl.value.isNotEmpty
                                    ? Image.network(
                                        idBackPicUrl.value,
                                        fit: BoxFit.cover,
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text('Back side'),
                                          SizedBox(height: 5.0),
                                          Icon(Icons.image, size: 50.0),
                                        ],
                                      )
                                : Image.file(idBack!, fit: BoxFit.cover),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 50.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () async {
                            formSubmitFunction(
                                formKey: _formKey,
                                submitFunction: () async {
                                  if (checkEmpty(idFrontPicUrl)) {
                                    Utils.toast("Provide profile picture");
                                    return;
                                  } else if (checkEmpty(idFrontPicUrl)) {
                                    Utils.toast("Provide ID front page");
                                    return;
                                  } else if (checkEmpty(idBackPicUrl)) {
                                    Utils.toast("Provide ID back page");
                                    return;
                                  } else {
                                    Utils.loading(
                                        msg: "Updating profile details...");
                                    if (profilePicFile != null) {
                                      profilePicUrl.value =
                                          await ProfileController.uploadImage(
                                              profilePicFile!);
                                      FirebaseAuth.instance.currentUser!
                                          .updatePhotoURL(profilePicUrl.value);
                                    }
                                    if (idFront != null) {
                                      idFrontPicUrl.value =
                                          await ProfileController.uploadImage(
                                              idFront!);
                                    }

                                    if (idBack != null) {
                                      idBackPicUrl.value =
                                          await ProfileController.uploadImage(
                                              idBack!);
                                    }

                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    await user
                                        ?.updatePhotoURL(profilePicUrl.value);
                                    await user?.reload();
                                    Map<String, dynamic> profilData = {
                                      'uid': user?.uid,
                                      'name': nameController.text,
                                      'email': user?.email,
                                      'isEmailVerified': user?.emailVerified,
                                      'phone': numberController.text.trim(),
                                      'photoUrl': profilePicUrl.value,
                                      'locality': localityController.text,
                                      'city': selectedCity.value,
                                      'state': selectedState.value,
                                      'preferedClass': selectedClass.value,
                                      'preferedSubject': selectedSubject.value,
                                      'preferedMode': selectedMode.value,
                                      'gender': selectedGender.value,
                                      'totalExp': selectedExp.value,
                                      'qualification': qualiController.text,
                                      'idType': selectedIdType.value,
                                      'idUrlFront': idFrontPicUrl.value,
                                      'idUrlBack': idBackPicUrl.value
                                    };
                                    await ProfileController.updateProfile(
                                        profileBody: profilData);
                                    ref.refresh(profileDataProvider);
                                    EasyLoading.dismiss();
                                    Future.delayed(Duration.zero).then((value) {
                                      context.go(AppRoutes.home);
                                    });
                                  }
                                });
                          },
                          child: const Text('Save and proceed')),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      )),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
      ),
    );
  }
}
