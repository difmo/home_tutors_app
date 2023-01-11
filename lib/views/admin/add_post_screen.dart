import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/statics.dart';

class EditPostModel {
  final String? id;
  final Map<String, dynamic>? data;
  EditPostModel({this.id, this.data});
}

class AddLeadScreen extends HookConsumerWidget {
  final EditPostModel? editData;
  AddLeadScreen({super.key, this.editData});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final feeController = useTextEditingController();

    final localityController = useTextEditingController();
    // final qualiController = useTextEditingController();
    final subjectController = useTextEditingController();

    final maxHitsController = useTextEditingController();
    final coinReqController = useTextEditingController();
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final classController = useTextEditingController();

    final selectedState = useState("");
    final selectedCity = useState("");

    // final selectedExp = useState("");

    final selectedMode = useState("");
    final selectedGender = useState("");

    useEffect(() {
      if (editData != null) {
        descController.text = editData?.data?["desc"];
        feeController.text = editData?.data?["fee"];
        classController.text = editData?.data?["class"];
        selectedMode.value = editData?.data?["mode"];
        subjectController.text = editData?.data?["subject"];
        localityController.text = editData?.data?["locality"];
        selectedState.value = editData?.data?["state"];
        selectedCity.value = editData?.data?["city"];
        selectedGender.value = editData?.data?["gender"];
        localityController.text = editData?.data?["locality"];
        maxHitsController.text = editData?.data?["max_hits"];
        coinReqController.text = editData?.data?["req_coins"];
        nameController.text = editData?.data?["name"];
        phoneController.text = editData?.data?["phone"];
      }
      return;
    }, []);

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextFormField(
                        //   validator: (value) {
                        //     if (value!.length < 3) {
                        //       return "Enter a valid title";
                        //     } else {
                        //       return null;
                        //     }
                        //   },
                        //   controller: titleController,
                        //   keyboardType: TextInputType.name,
                        //   maxLength: 50,
                        //   decoration: const InputDecoration(
                        //     hintText: "Ex: English teacher",
                        //     label: Text('Title'),
                        //   ),
                        // ),
                        TextFormField(
                          validator: (value) {
                            if (value!.length < 3) {
                              return "Enter a valid description";
                            } else {
                              return null;
                            }
                          },
                          controller: descController,
                          keyboardType: TextInputType.text,
                          maxLength: 500,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "More detials",
                            label: Text('Description'),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.length < 2) {
                              return "enter a valid fee";
                            } else {
                              return null;
                            }
                          },
                          controller: feeController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: "Fee in INR",
                            label: Text('Fee'),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Text(
                          'Class preferences:',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          maxLength: 20,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Enter a valid class";
                            } else {
                              return null;
                            }
                          },
                          controller: classController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: "10th / 12th",
                            label: Text('Class'),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        DropdownSearch<String>(
                          validator: (value) {
                            if (checkEmpty(value)) {
                              return "Choose teaching mode";
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
                              labelText: "Teaching Mode",
                              hintText: "Online/Offline/Any",
                            ),
                          ),
                          onChanged: (value) {
                            selectedMode.value = value!;
                          },
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          maxLength: 35,
                          validator: (value) {
                            if (value!.length < 2) {
                              return "Enter a valid subject";
                            } else {
                              return null;
                            }
                          },
                          controller: subjectController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: "Provide subject",
                            label: Text('Subject'),
                          ),
                        ),

                        const SizedBox(height: 30.0),
                        Text(
                          'Location preferences:',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
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
                                        dropdownSearchDecoration:
                                            InputDecoration(
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
                        // Text(
                        //   'Qualification preferences:',
                        //   style: TextStyle(
                        //     fontSize: 20.0,
                        //     color: Colors.blue.shade900,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        // const SizedBox(height: 10.0),
                        // DropdownSearch<String>(
                        //   validator: (value) {
                        //     if (checkEmpty(value)) {
                        //       return "Select total experience ";
                        //     } else {
                        //       return null;
                        //     }
                        //   },
                        //   selectedItem: selectedExp.value.isEmpty
                        //       ? null
                        //       : selectedExp.value,
                        //   popupProps:
                        //       const PopupProps.menu(showSelectedItems: true),
                        //   items: List<String>.generate(
                        //       30, (i) => (i + 1).toString()),
                        //   dropdownDecoratorProps: const DropDownDecoratorProps(
                        //     dropdownSearchDecoration: InputDecoration(
                        //       labelText: "Total Experience",
                        //       hintText: "10 years or any other",
                        //     ),
                        //   ),
                        //   onChanged: (value) {
                        //     selectedExp.value = value!;
                        //   },
                        // ),
                        // TextFormField(
                        //   validator: (value) {
                        //     if (value!.length < 2) {
                        //       return "Enter valid Qualification";
                        //     } else {
                        //       return null;
                        //     }
                        //   },
                        //   controller: qualiController,
                        //   keyboardType: TextInputType.text,
                        //   maxLength: 50,
                        //   decoration: const InputDecoration(
                        //     hintText: "B.A/ M-TECH",
                        //     label: Text('Qualification'),
                        //   ),
                        // ),
                        // const SizedBox(height: 30.0),
                        Text(
                          'Other preferences:',
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
                              return "Select gender preference";
                            } else {
                              return null;
                            }
                          },
                          selectedItem: selectedGender.value.isEmpty
                              ? null
                              : selectedGender.value,
                          popupProps:
                              const PopupProps.menu(showSelectedItems: true),
                          items: const ["Male", "Female", "Any"],
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Gender preference",
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
                            if (value!.isEmpty) {
                              return "Enter max hits";
                            } else {
                              return null;
                            }
                          },
                          controller: maxHitsController,
                          inputFormatters: numberOnlyInput,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          decoration: const InputDecoration(
                            hintText: "Max hits",
                            label: Text('Max hits'),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter valid required coins";
                            } else {
                              return null;
                            }
                          },
                          controller: coinReqController,
                          inputFormatters: numberOnlyInput,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          decoration: const InputDecoration(
                            hintText: "Required coins",
                            label: Text('Required coins'),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Text(
                          'Contact details:',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter valid name";
                            } else {
                              return null;
                            }
                          },
                          maxLength: 50,
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: "Full name",
                            label: Text('Name'),
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.length != 10) {
                              return "Enter 10 digit valid phone number";
                            } else {
                              return null;
                            }
                          },
                          controller: phoneController,
                          inputFormatters: numberOnlyInput,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            hintText: "10 digit number",
                            label: Text('Contact number'),
                          ),
                        ),

                        const SizedBox(height: 50.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                              onPressed: () async {
                                formSubmitFunction(
                                    formKey: _formKey,
                                    submitFunction: () async {
                                      Map<String, dynamic> postBody = {
                                        "desc": descController.text,
                                        "fee": feeController.text,
                                        "class": classController.text,
                                        "mode": selectedMode.value,
                                        "subject": subjectController.text,
                                        "locality": localityController.text,
                                        "state": selectedState.value,
                                        "city": selectedCity.value,
                                        "gender": selectedGender.value,
                                        "max_hits":
                                            maxHitsController.text.trim(),
                                        "req_coins":
                                            coinReqController.text.trim(),
                                        "name": nameController.text,
                                        "phone": phoneController.text,
                                        "email": adminContactMail,
                                      };

                                      if (editData != null) {
                                        Utils.loading(msg: "Updating lead...");
                                        await AdminControllers.editLead(
                                            data: postBody,
                                            docId: editData?.id);
                                      } else {
                                        Utils.loading(
                                            msg: "Creating new lead...");
                                        int lastLeadNo =
                                            await AdminControllers.lastPostId();
                                        postBody['id'] = lastLeadNo + 1;
                                        postBody['createdOn'] =
                                            FieldValue.serverTimestamp();
                                        postBody['users'] =
                                            FieldValue.arrayUnion([""]);

                                        await AdminControllers.createLeads(
                                            postBody: postBody);
                                      }
                                      EasyLoading.dismiss();
                                      Future.delayed(Duration.zero)
                                          .then((value) {
                                        context.go(AppRoutes.adminHome);
                                      });
                                    });
                              },
                              child: const Text('Save and proceed')),
                        )
                      ],
                    ),
                  )))),
      appBar: AppBar(
        title: const Text('New post'),
        centerTitle: false,
      ),
    );
  }
}
