import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants.dart';
import '../posts/post_details.dart';

class UserDetailsScreen extends HookConsumerWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? item;
  const UserDetailsScreen({super.key, this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = useState(profileStatusList[0]);
    final walletController = useTextEditingController(
        text: (item?["wallet_balance"] ?? 0).toString());
    useEffect(
      () {
        for (var element in profileStatusList) {
          if (element.status == item?["status"]) {
            selectedStatus.value = element;
          }
        }
        if (checkEmpty(item?["name"])) {
          AdminControllers.sendNotification(
              deviceToken: item?["fcm_token"],
              title: "Complete your profile",
              body: "Complete your profile to verify your account");
        }
        return () {};
      },
      [],
    );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!checkEmpty(item?["photoUrl"]))
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: checkEmpty(item?["photoUrl"])
                            ? null
                            : NetworkImage(item?["photoUrl"]),
                        child: checkEmpty(item?["photoUrl"])
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    const SizedBox(width: 25.0),
                    Expanded(child: Text(item?["name"], style: pagetitleStyle)),
                  ],
                ),
                const SizedBox(height: 25.0),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                        formatWithMonthNameTime
                            .format(item?["createdOn"].toDate()),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12.0))),
                DetailsTileWidget(
                  icon: item?["gender"] == "Male" ? Icons.male : Icons.female,
                  title: item?["gender"],
                ),
                InkWell(
                  onTap: () {
                    openUrl("mailto:${item?["email"]}");
                  },
                  child: DetailsTileWidget(
                    icon: Icons.email,
                    title: item?["email"],
                  ),
                ),
                InkWell(
                  onTap: () {
                    openUrl("tel:${item?["phone"]}");
                  },
                  child: DetailsTileWidget(
                    icon: Icons.phone,
                    title: item?["phone"],
                  ),
                ),
                DetailsTileWidget(
                  icon: Icons.location_city,
                  title: item?["state"],
                ),
                DetailsTileWidget(
                  icon: Icons.location_on,
                  title: item?["state"],
                ),
                DetailsTileWidget(
                  icon: Icons.home,
                  title: item?["locality"],
                ),
                DetailsTileWidget(
                    icon: Icons.edit_note_sharp,
                    title: "Class: ${item?["preferedClass"]}"),
                DetailsTileWidget(
                    icon: Icons.switch_video_outlined,
                    title: "Mode: ${item?["preferedMode"]}"),
                DetailsTileWidget(
                    icon: Icons.work,
                    title: "Experience: ${item?["totalExp"]} years"),
                DetailsTileWidget(
                    icon: Icons.school,
                    title: "Qualification: ${item?["qualification"]}"),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    if (!checkEmpty(item?["idUrlFront"]))
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            context.push(AppRoutes.imageView,
                                extra: item?["idUrlFront"]);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: const EdgeInsets.all(5.0),
                              height: 100,
                              child: !checkEmpty(item)
                                  ? Image.network(
                                      item?["idUrlFront"],
                                      fit: BoxFit.cover,
                                    )
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
                                    )),
                        ),
                      ),
                    if (!checkEmpty(item?["idUrlBack"]))
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            context.push(AppRoutes.imageView,
                                extra: item?["idUrlBack"]);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10.0)),
                              margin: const EdgeInsets.all(5.0),
                              height: 100,
                              child: !checkEmpty(item)
                                  ? Image.network(
                                      item?["idUrlBack"],
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
                                    )),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                DropdownSearch<ProfileStatusModel>(
                  popupProps: const PopupProps.modalBottomSheet(),
                  validator: (value) {
                    if (checkEmpty(value)) {
                      return "Choose status";
                    } else {
                      return null;
                    }
                  },
                  selectedItem: selectedStatus.value,
                  items: profileStatusList,
                  itemAsString: (item) {
                    return item.title;
                  },
                  onChanged: (value) async {
                    selectedStatus.value = value!;
                    Utils.loading();
                    await ProfileController.updateProfile(
                        profileBody: {"status": selectedStatus.value.status},
                        uidFromAdmin: item?["uid"]);
                    await AdminControllers.sendNotification(
                        deviceToken: item?["fcm_token"],
                        title: "Account reviewed by Admin",
                        body: "Check your account status");
                    EasyLoading.dismiss();
                  },
                ),
                const SizedBox(height: 20.0),
                TextField(
                  inputFormatters: numberOnlyInput,
                  controller: walletController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Wallet Balance",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) async {
                    Utils.loading();
                    await ProfileController.updateProfile(profileBody: {
                      "wallet_balance": checkEmpty(walletController.text)
                          ? 0
                          : int.parse(walletController.text)
                    }, uidFromAdmin: item?["uid"]);
                    EasyLoading.dismiss();
                  },
                ),
                const SizedBox(height: 100.0),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(item?["name"]),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz,
        children: [
          SpeedDialChild(
              label: "Edit",
              backgroundColor: Colors.green,
              child: const Icon(Icons.edit),
              onTap: () async {
                context.push(AppRoutes.teacherProfile, extra: item?.id);
              }),
          SpeedDialChild(
              backgroundColor: Colors.green,
              child: const Icon(Icons.delete),
              onTap: () async {
                Utils.loading();
                await AdminControllers.deleteUser(userId: item!.id);
                EasyLoading.dismiss();
                Future.delayed(Duration.zero).then((value) {
                  context.pop();
                });
              }),
        ],
      ),
    );
  }
}

class ProfileStatusModel {
  final int status;
  final String title;

  ProfileStatusModel({required this.status, required this.title});
}

final List<ProfileStatusModel> profileStatusList = [
  ProfileStatusModel(title: "Pending", status: 0),
  ProfileStatusModel(title: "Approved", status: 1),
  ProfileStatusModel(title: "Declined", status: 2),
];
