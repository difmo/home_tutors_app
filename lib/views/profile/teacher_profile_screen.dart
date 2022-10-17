import 'dart:io';

import 'package:app/controllers/routes.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/statics.dart';

// ignore: must_be_immutable
class TeacherProfileScreen extends HookConsumerWidget {
  TeacherProfileScreen({super.key});
  final ImagePicker _picker = ImagePicker();

  File? profilePicFile;
  File? idFront;
  File? idBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reBuild = useState(false);
    final nameController = useTextEditingController();
    final numberController = useTextEditingController();
    final localityController = useTextEditingController();
    final qualiController = useTextEditingController();

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
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () async {
                        final XFile? profilePic =
                            await _picker.pickImage(source: ImageSource.camera);
                        if (profilePic != null) {
                          profilePicFile = File(profilePic.path);
                          reBuild.value = !reBuild.value;
                        }
                      },
                      child: profilePicFile == null
                          ? const CircleAvatar(
                              radius: 40.0,
                              backgroundImage:
                                  AssetImage('assets/placeholder_user.jpeg'))
                          : CircleAvatar(
                              radius: 40.0,
                              backgroundImage: FileImage(profilePicFile!),
                            )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
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
                popupProps: const PopupProps.menu(showSelectedItems: true),
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
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: "10 digit mobile number",
                  label: Text('Phone number'),
                ),
              ),
              TextField(
                controller: localityController,
                keyboardType: TextInputType.streetAddress,
                maxLength: 50,
                decoration: const InputDecoration(
                  hintText: "Nearby or street name",
                  label: Text('Locality'),
                ),
              ),
              DropdownSearch<String>(
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
                            popupProps: const PopupProps.menu(
                                showSelectedItems: true, showSearchBox: true),
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
                popupProps: const PopupProps.menu(showSelectedItems: true),
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
                popupProps: const PopupProps.menu(showSelectedItems: true),
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
                popupProps: const PopupProps.menu(showSelectedItems: true),
                items: List<String>.generate(30, (i) => (i + 1).toString()),
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
              TextField(
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
                popupProps: const PopupProps.menu(showSelectedItems: true),
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
                      final XFile? idFrontPic =
                          await _picker.pickImage(source: ImageSource.camera);
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
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      final XFile? idBackPic =
                          await _picker.pickImage(source: ImageSource.camera);
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
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                    child: const Text('Save and proceed')),
              )
            ],
          ),
        ),
      )),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
      ),
    );
  }
}
