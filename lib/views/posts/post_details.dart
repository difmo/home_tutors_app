import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/profile_controllers.dart';
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
            if (postData?["users"][i] == UserControllers.currentUser!.email) {
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
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      formatWithMonthNameTime
                          .format(postData?["createdOn"].toDate()),
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0))),
              DetailsTileWidget(
                  icon: Icons.edit_note_sharp,
                  title: "Class: ${postData?["class"]}"),
              DetailsTileWidget(icon: Icons.book, title: postData?["subject"]),

              DetailsTileWidget(
                  icon: Icons.location_on,
                  title: postData?["city"] + " - " + postData?["state"],
                  subTitle: postData?["locality"]),

              DetailsTileWidget(
                  icon: Icons.monetization_on,
                  title: "Fee: ₹${postData?["fee"]} per hour"),
              DetailsTileWidget(
                  icon: Icons.switch_video_outlined,
                  title: "Mode: ${postData?["mode"]}"),
              DetailsTileWidget(
                  icon:
                      postData?["gender"] == "Male" ? Icons.male : Icons.female,
                  title: " Tutor Gender: ${postData?["gender"]}"),

              const SizedBox(height: 15.0),

              const Text("Note: ", style: pageSubTitleStyle),
              const SizedBox(height: 10.0),

              Text(postData?["desc"]),
              const SizedBox(height: 15.0),

              // DetailsTileWidget(
              //     icon: Icons.work,
              //     title: "Prefered Experience: ${postData?["req_exp"]} years"),
              // DetailsTileWidget(
              //     icon: Icons.school,
              //     title: "Prefered Qualification: ${postData?["qualify"]}"),

              if (ifPurchased.value) ...[
                DetailsTileWidget(
                    icon: Icons.person,
                    title: "Contact name: ${postData?["name"]}"),
                DetailsTileWidget(
                    icon: Icons.phone,
                    title: "Contact number: ${postData?["phone"]}"),
                DetailsTileWidget(
                    icon: Icons.email,
                    title: "Contact email: ${postData?["email"]}"),
              ] else ...[
                DetailsTileWidget(
                    icon: Icons.wallet,
                    title: "Coins needed: ${postData?["req_coins"]}"),
                DetailsTileWidget(
                    icon: Icons.people,
                    title:
                        "${(postData?["users"].length) - 1} out of ${postData?["max_hits"]} Responded"),
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
                              onTap: () {},
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
          "Lead No: ${postData?["id"]}",
          style: pagetitleStyle,
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
