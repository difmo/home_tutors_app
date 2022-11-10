import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/profile_provider.dart';

class PostDetailsScreen extends HookConsumerWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? postData;
  const PostDetailsScreen({super.key, required this.postData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ifPurchased = useState(false);

    useEffect(
      () {
        for (var i = 0; i < postData?["users"].length; i++) {
          if (postData?["users"][i] != {}) {
            if (postData?["users"][i] ==
                UserControllers.currentUser!.phoneNumber) {
              ifPurchased.value = true;
            }
          }
        }
        return () {};
      },
      [],
    );
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15.0),
              Row(
                children: [
                  const Text(
                    "Lead No: ",
                    style: pageSubTitleStyle,
                  ),
                  Text(
                    "${postData?["id"]}",
                    style: pageSubTitleStyle.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              DetailsColorTileWidget(
                icon: Icons.class_,
                title: "Class: ",
                value: "${postData?["class"]}",
              ),
              DetailsColorTileWidget(
                icon: Icons.school,
                title: "Subject: ",
                value: "${postData?["subject"]}",
              ),
              DetailsColorTileWidget(
                icon: Icons.location_on,
                title: "",
                value: postData?["city"] + " - " + postData?["state"],
              ),
              Row(
                children: [
                  const Text(
                    "Locality: ",
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    "${postData?["locality"]}",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              DetailsColorTileWidget(
                icon: Icons.monetization_on,
                title: "Fee: ",
                value: "₹${postData?["fee"]}",
              ),
              DetailsColorTileWidget(
                icon: Icons.switch_video_outlined,
                title: "Mode: ",
                value: "${postData?["mode"]}",
              ),
              DetailsColorTileWidget(
                icon: postData?["gender"] == "Male" ? Icons.male : Icons.female,
                title: "Tutor Gender: ",
                value: "${postData?["gender"]}",
              ),

              const SizedBox(height: 15.0),

              const Text("Note: ", style: pageSubTitleStyle),
              const SizedBox(height: 10.0),

              Text(
                postData?["desc"],
                style: const TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 15.0),

              // DetailsTileWidget(
              //     icon: Icons.work,
              //     title: "Prefered Experience: ${postData?["req_exp"]} years"),
              // DetailsTileWidget(
              //     icon: Icons.school,
              //     title: "Prefered Qualification: ${postData?["qualify"]}"),

              if (ifPurchased.value || AuthControllers.isAdmin()) ...[
                DetailsColorTileWidget(
                  icon: Icons.person,
                  title: "Contact name: ",
                  value: "${postData?["name"]}",
                ),
                InkWell(
                  onTap: () {
                    openUrl("tel:${postData?["phone"]}");
                  },
                  child: DetailsColorTileWidget(
                    icon: Icons.phone,
                    title: "Contact number: ",
                    value: "${postData?["phone"]}",
                  ),
                ),
                InkWell(
                  onTap: () {
                    openUrl("mailto:${postData?["email"]}");
                  },
                  child: DetailsColorTileWidget(
                    icon: Icons.email,
                    title: "Contact email: ",
                    value: "${postData?["email"]}",
                  ),
                ),
              ] else ...[
                DetailsColorTileWidget(
                  icon: Icons.wallet,
                  title: "Coins needed: ",
                  value: "${postData?["req_coins"]}",
                ),
                Row(
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 5.0),
                    Text(
                      "${(postData?["users"].length) - 1} ",
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Text(
                      "out of ",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Text(
                      "${postData?["max_hits"]}",
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Text(
                      " Responded",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                )
              ],
              if (AuthControllers.isAdmin()) ...[
                const SizedBox(height: 25.0),
                const Text("Collected users", style: pagetitleStyle),
                ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: postData?["users"].length,
                    itemBuilder: (context, index) {
                      return postData?["users"][index].isEmpty
                          ? const SizedBox.shrink()
                          : ListTile(
                              onTap: () async {
                                if (!checkEmpty(postData?["users"][index])) {
                                  Utils.loading();
                                  var data =
                                      await AdminControllers.fetchProfileData(
                                          postData?["users"][index]);
                                  EasyLoading.dismiss();
                                  Future.delayed(Duration.zero).then((value) {
                                    context.push(AppRoutes.userDetails,
                                        extra: data);
                                  });
                                }
                              },
                              leading: Text(index.toString()),
                              title: Text(postData?["users"][index]),
                            );
                    }),
                const SizedBox(height: 50.0),
              ]
            ],
          ),
        ),
      )),
      appBar: AppBar(
        title: Text(
          formatWithMonthNameTime.format(postData?["createdOn"].toDate()),
        ),
      ),
      floatingActionButton: AuthControllers.isAdmin()
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              child: const Icon(Icons.delete),
              onPressed: () async {
                Utils.loading();
                await AdminControllers.deleteLead(postId: postData!.id);
                EasyLoading.dismiss();
                Future.delayed(Duration.zero).then((value) {
                  context.pop();
                });
              })
          : ifPurchased.value
              ? null
              : (postData?["users"].length - 1) >=
                      int.parse(postData?["max_hits"])
                  ? null
                  : InkWell(
                      onTap: () async {
                        if ((postData?["users"].length - 1) <
                            int.parse(postData?["max_hits"])) {
                          Utils.loading();
                          var profileData =
                              await ProfileController().fetchProfileData();
                          if (profileData?["wallet_balance"] >=
                              int.parse(postData?["req_coins"])) {
                            UserControllers.addUidIntoPost(
                                postId: postData!.id);
                            EasyLoading.dismiss();
                            ProfileController.updateProfile(profileBody: {
                              "wallet_balance":
                                  (profileData?["wallet_balance"] -
                                      int.parse(postData?["req_coins"]))
                            });
                            ref.refresh(profileDataProvider);
                            ifPurchased.value = true;
                          } else {
                            EasyLoading.showError("Please upgrade your wallet");
                            EasyLoading.dismiss();
                          }
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            "Grab Lead",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          )),
                    ),
    );
  }
}

class DetailsTileWidget extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? subTitle;

  const DetailsTileWidget(
      {super.key, required this.icon, required this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title ?? ""),
      subtitle: subTitle == null ? null : Text(subTitle ?? ""),
    );
  }
}

class DetailsColorTileWidget extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? value;

  const DetailsColorTileWidget(
      {super.key,
      required this.icon,
      required this.title,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 5.0),
          Text(title ?? ""),
          Text(
            value ?? "",
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
