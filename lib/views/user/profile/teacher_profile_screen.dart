import 'dart:io';

import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/statics.dart';
import '../../../models/place_details_model.dart';
import '../../widgets/location/location_search_screen.dart';

// ignore: must_be_immutable
class TeacherProfileScreen extends HookConsumerWidget {
  final String? uid;
  TeacherProfileScreen({super.key, this.uid});
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reBuild = useState(false);
    final firstLoad = useState(false);

    final nameController = useTextEditingController();
    final emailController = useTextEditingController();

    final localityController = useTextEditingController();
    final locationPosition = useState<GeoPoint?>(null);

    final qualiController = useTextEditingController();

    final selectedClasses = useState<List>([]);

    final profilePicFile = useState<File?>(null);
    final idFront = useState<File?>(null);
    final idBack = useState<File?>(null);

    final profilePicUrl = useState("");
    final idFrontPicUrl = useState("");
    final idBackPicUrl = useState("");

    final selectedState = useState("");
    final selectedCity = useState("");
    final selectedSubjects = useState<List>([]);

    final selectedExp = useState("");
    final selectedIdType = useState("");

    final selectedMode = useState("");
    final selectedGender = useState("");
    final profileStatus = useState(0);

    return Scaffold(
      body: SafeArea(
          child:
              ref.watch(profileDataProvider(uid ?? auth.currentUser?.uid)).when(
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
          if (!firstLoad.value && data != null) {
            nameController.text = data["name"];
            profilePicUrl.value = data["photoUrl"];
            idFrontPicUrl.value = data["idUrlFront"];
            idBackPicUrl.value = data["idUrlBack"];
            emailController.text = data["email"];
            locationPosition.value = data["location"];
            localityController.text = data["locality"];
            qualiController.text = data["qualification"];
            selectedGender.value = data["gender"];
            selectedState.value = data["state"];
            selectedCity.value = data["city"];
            selectedClasses.value = data["preferedClassList"] ?? [];
            selectedSubjects.value = data["preferedSubjectList"] ?? [];
            selectedExp.value = data["totalExp"];
            selectedIdType.value = data["idType"];
            selectedMode.value = data["preferedMode"];
            profileStatus.value = data["status"];
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
                              showModalBottomSheet<XFile?>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                                label: const Text('Gallery'),
                                                icon: const Icon(
                                                    Icons.photo_library),
                                                onPressed: () async {
                                                  final XFile? profilePic =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          imageQuality: 10,
                                                          preferredCameraDevice:
                                                              CameraDevice
                                                                  .front);
                                                  if (profilePic != null) {
                                                    profilePicFile.value =
                                                        File(profilePic.path);
                                                    reBuild.value =
                                                        !reBuild.value;
                                                    context.pop();
                                                  }
                                                }),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              label: const Text('Camera'),
                                              icon:
                                                  const Icon(Icons.camera_alt),
                                              onPressed: () async {
                                                final XFile? profilePic =
                                                    await _picker.pickImage(
                                                        source:
                                                            ImageSource.camera,
                                                        imageQuality: 10,
                                                        preferredCameraDevice:
                                                            CameraDevice.front);
                                                if (profilePic != null) {
                                                  profilePicFile.value =
                                                      File(profilePic.path);
                                                  reBuild.value =
                                                      !reBuild.value;
                                                  context.pop();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: profilePicFile.value == null
                                ? profilePicUrl.value.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage:
                                            NetworkImage(profilePicUrl.value))
                                    : const CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage: AssetImage(
                                            'assets/images/placeholder_user.jpeg'))
                                : CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage:
                                        FileImage(profilePicFile.value!),
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
                        if (!value!.isValidEmail()) {
                          return "Enter valid email";
                        } else {
                          return null;
                        }
                      },
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        hintText: "user@mail.com",
                        label: Text('Email'),
                      ),
                    ),
                    TextFormField(
                      readOnly: true,
                      onTap: () async {
                        PlaceDetailsModel? data = await showDialog(
                          context: context,
                          builder: (context) {
                            return const SearchLocationScreen();
                          },
                        );
                        if (data != null) {
                          localityController.text = data.result?.vicinity ?? "";
                          locationPosition.value = GeoPoint(
                              data.result?.geometry?.location?.lat ?? 0.0,
                              data.result?.geometry?.location?.lng ?? 0.0);
                          for (var element in data.result!.addressComponents!) {
                            if (element?.types?.first ==
                                "administrative_area_level_1") {
                              selectedState.value = element!.longName ?? "";
                            }
                            if (element?.types?.first ==
                                "administrative_area_level_3") {
                              selectedCity.value = element!.longName ?? "";
                            }
                          }
                        }
                      },
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
                    DropdownSearch<String>.multiSelection(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Choose prefered classes";
                        } else {
                          return null;
                        }
                      },
                      items: preferredClassList,
                      popupProps: const PopupPropsMultiSelection.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Prefered Classes",
                          hintText: "You can choose multiple",
                        ),
                      ),
                      selectedItems: selectedClasses.value.cast<String>(),
                      onChanged: (newValue) {
                        if (!checkEmpty(newValue)) {
                          selectedClasses.value = newValue.cast<String>();
                        }
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
                      items: const ["Online", "Offline", "Both"],
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Prefered Mode",
                          hintText: "Online/offline/Both",
                        ),
                      ),
                      onChanged: (value) {
                        selectedMode.value = value!;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    DropdownSearch<String>.multiSelection(
                      validator: (value) {
                        if (checkEmpty(value)) {
                          return "Choose prefered subjects";
                        } else {
                          return null;
                        }
                      },
                      items: subjectList,
                      popupProps: const PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Prefered Subjects",
                          hintText: "You can choose multiple",
                        ),
                      ),
                      selectedItems: selectedSubjects.value.cast<String>(),
                      onChanged: (newValue) {
                        if (!checkEmpty(newValue)) {
                          selectedSubjects.value = newValue.cast<String>();
                        }
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
                    if (profileStatus.value == 0) ...[
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
                        items: const ["Aadhar Card", "Voter Card", "Other"],
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
                              showModalBottomSheet<XFile?>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                                label: const Text('Gallery'),
                                                icon: const Icon(
                                                    Icons.photo_library),
                                                onPressed: () async {
                                                  final XFile? idFrontPic =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          imageQuality: 10,
                                                          preferredCameraDevice:
                                                              CameraDevice
                                                                  .rear);
                                                  if (idFrontPic != null) {
                                                    idFront.value =
                                                        File(idFrontPic.path);
                                                    reBuild.value =
                                                        !reBuild.value;

                                                    context.pop();
                                                  }
                                                }),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              label: const Text('Camera'),
                                              icon:
                                                  const Icon(Icons.camera_alt),
                                              onPressed: () async {
                                                final XFile? idFrontPic =
                                                    await _picker.pickImage(
                                                        source:
                                                            ImageSource.camera,
                                                        imageQuality: 10,
                                                        preferredCameraDevice:
                                                            CameraDevice.rear);
                                                if (idFrontPic != null) {
                                                  idFront.value =
                                                      File(idFrontPic.path);
                                                  reBuild.value =
                                                      !reBuild.value;

                                                  context.pop();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: const EdgeInsets.all(5.0),
                              height: 100,
                              child: idFront.value == null
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
                                      idFront.value!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          )),
                          Expanded(
                              child: InkWell(
                            onTap: () async {
                              showModalBottomSheet<XFile?>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                                label: const Text('Gallery'),
                                                icon: const Icon(
                                                    Icons.photo_library),
                                                onPressed: () async {
                                                  final XFile? idBackPic =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          imageQuality: 10,
                                                          preferredCameraDevice:
                                                              CameraDevice
                                                                  .rear);
                                                  if (idBackPic != null) {
                                                    idBack.value =
                                                        File(idBackPic.path);
                                                    reBuild.value =
                                                        !reBuild.value;

                                                    context.pop();
                                                  }
                                                }),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              label: const Text('Camera'),
                                              icon:
                                                  const Icon(Icons.camera_alt),
                                              onPressed: () async {
                                                final XFile? idBackPic =
                                                    await _picker.pickImage(
                                                        source:
                                                            ImageSource.camera,
                                                        imageQuality: 10,
                                                        preferredCameraDevice:
                                                            CameraDevice.rear);
                                                if (idBackPic != null) {
                                                  idBack.value =
                                                      File(idBackPic.path);
                                                  reBuild.value =
                                                      !reBuild.value;

                                                  context.pop();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: const EdgeInsets.all(5.0),
                              height: 100,
                              child: idBack.value == null
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
                                  : Image.file(idBack.value!,
                                      fit: BoxFit.cover),
                            ),
                          )),
                        ],
                      ),
                    ],
                    const SizedBox(height: 50.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () async {
                            formSubmitFunction(
                                formKey: _formKey,
                                submitFunction: () async {
                                  if (checkEmpty(profilePicUrl.value) &&
                                      profilePicFile.value == null) {
                                    Fluttertoast.showToast(
                                        msg: "Provide profile picture",
                                        backgroundColor: Colors.red);
                                    return;
                                  } else if (checkEmpty(idFrontPicUrl.value) &&
                                      idFront.value == null) {
                                    Fluttertoast.showToast(
                                        msg: "Provide ID front page",
                                        backgroundColor: Colors.red);
                                    return;
                                  } else if (checkEmpty(idBackPicUrl.value) &&
                                      idBack.value == null) {
                                    Fluttertoast.showToast(
                                        msg: "Provide ID back page",
                                        backgroundColor: Colors.red);
                                    return;
                                  } else {
                                    Utils.loading(
                                        msg: "Updating profile details...");
                                    if (profilePicFile.value != null) {
                                      profilePicUrl.value =
                                          await ProfileController.uploadImage(
                                              profilePicFile.value!);
                                      FirebaseAuth.instance.currentUser!
                                          .updatePhotoURL(profilePicUrl.value);
                                    }
                                    if (idFront.value != null) {
                                      idFrontPicUrl.value =
                                          await ProfileController.uploadImage(
                                              idFront.value!);
                                    }

                                    if (idBack.value != null) {
                                      idBackPicUrl.value =
                                          await ProfileController.uploadImage(
                                              idBack.value!);
                                    }
                                    if (uid == null) {
                                      User? user =
                                          FirebaseAuth.instance.currentUser;
                                      await user
                                          ?.updatePhotoURL(profilePicUrl.value);
                                      await user?.reload();
                                    }
                                    final geo = GeoFlutterFire();
                                    GeoFirePoint position = geo.point(latitude: locationPosition.value!.latitude, longitude: locationPosition.value!.longitude);

                                    Map<String, dynamic> profilData = {
                                      'name': nameController.text,
                                      'email': emailController.text.trim(),
                                      'photoUrl': profilePicUrl.value,
                                      'locality': localityController.text,
                                      'city': selectedCity.value,
                                      'state': selectedState.value,
                                      "location": locationPosition.value,
                                      "position":position.data,
                                      'preferedClass':
                                          selectedClasses.value.join(', '),
                                      'preferedClassList':
                                          selectedClasses.value,
                                      'preferedSubject':
                                          selectedSubjects.value.join(', '),
                                      'preferedSubjectList':
                                          selectedSubjects.value,
                                      'preferedMode': selectedMode.value,
                                      'gender': selectedGender.value,
                                      'totalExp': selectedExp.value,
                                      'qualification': qualiController.text,
                                      'idType': selectedIdType.value,
                                      'idUrlFront': idFrontPicUrl.value,
                                      'idUrlBack': idBackPicUrl.value,
                                      'status': uid == null ? 0 : 1,
                                      'createdOn': FieldValue.serverTimestamp(),
                                    };
                                    await ProfileController.updateProfile(
                                        profileBody: profilData,
                                        uidFromAdmin: uid);
                                    ref.refresh(profileDataProvider(
                                        uid ?? auth.currentUser?.uid));
                                    EasyLoading.dismiss();
                                    // if (data?["state"] != selectedState.value) {
                                    //   stateNameStateProvider.state =
                                    //       selectedState.value;
                                    // }
                                    Future.delayed(Duration.zero).then((value) {
                                      if (uid != null) {
                                        context.pop();
                                        context.pop();
                                      } else {
                                        context.go(AppRoutes.home);
                                      }
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
