import 'dart:developer';

import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/constants.dart';
import 'package:app/views/posts/widgets/collected_users.dart';
import 'package:app/views/posts/widgets/matched_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/statics.dart';
import '../../providers/profile_provider.dart';
import '../admin/add_post_screen.dart';
import '../admin/widgets/clear_data_confirm_widget.dart';

class PostDetailsScreen extends HookConsumerWidget {
  final String id;
  final Map<String, dynamic>? data;
  PostDetailsScreen({super.key, required this.id, required this.data});
  final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2, initialIndex: 0);
    final selectedIndex = useState(0);
    final ifPurchased = useState(false);
    final postData = useState<Map<String, dynamic>?>({});
    final postId = useState("");
    final getData = useCallback((String id) async {
      postData.value = await UserControllers.getPostData(id);
    }, []);
    final radius = useState(5.0);
    final deepLinking = useCallback(() async {
      final deepLinkData = await dynamicLinks.getInitialLink();
      final deepLink = deepLinkData?.link;
      if (deepLink != null) {
        if (deepLink.queryParameters.isNotEmpty) {
          postId.value = deepLink.queryParameters["id"] ?? "";
          getData(postId.value);
        }
      }
    }, []);
    final getLink = useCallback(() async {
      Utils.loading(msg: "Creating link");
      DynamicLinkParameters parameters = DynamicLinkParameters(
          link: Uri.parse(
              websiteUrl + ("${AppRoutes.postDetails}?id=${postId.value}")),
          uriPrefix: dynamicUriPrifix,
          androidParameters: const AndroidParameters(
              packageName: "com.viptutors.app", minimumVersion: 0));
      final Uri dynamicLink = await dynamicLinks.buildLink(parameters);
      EasyLoading.dismiss();
      return dynamicLink;
    }, []);

    useEffect(
      () {
        deepLinking();
        dynamicLinks.onLink.listen((event) {
          final Uri url = event.link;
          final queryParams = url.queryParameters;
          if (queryParams.isNotEmpty) {
            postId.value = queryParams["id"] ?? "";
            getData(postId.value);
          }
        });
        if (data != null) {
          postData.value = data;
          postId.value = id;
          for (var i = 0; i < postData.value?["users"].length; i++) {
            if (postData.value?["users"][i] != {}) {
              if (postData.value?["users"][i] ==
                  UserControllers.currentUser!.phoneNumber) {
                ifPurchased.value = true;
              }
            }
          }
        }

        return;
      },
      [],
    );
    return checkEmpty(postData.value)
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                                "${postData.value?["id"]}",
                                style: pageSubTitleStyle.copyWith(
                                    color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          DetailsColorTileWidget(
                            icon: Icons.class_,
                            title: "Class: ",
                            value:
                                "${postData.value?["class"]} ${postData.value?["board"] ?? ""}",
                          ),
                          DetailsColorTileWidget(
                            icon: Icons.school,
                            title: "Subject: ",
                            value: "${postData.value?["subject"]}",
                          ),
                          DetailsColorTileWidget(
                            icon: Icons.location_on,
                            title: "",
                            value:
                                "${postData.value?["city"]} - ${postData.value?["state"]}",
                          ),
                          Row(
                            children: [
                              const Text(
                                "Locality: ",
                              ),
                              const SizedBox(width: 5.0),
                              Flexible(
                                child: Text(
                                  "${postData.value?["locality"]}",
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          DetailsColorTileWidget(
                            icon: Icons.monetization_on,
                            title: "Fee: ",
                            value: "₹${postData.value?["fee"]}",
                          ),
                          DetailsColorTileWidget(
                            icon: Icons.switch_video_outlined,
                            title: "Mode: ",
                            value: "${postData.value?["mode"]}",
                          ),
                          DetailsColorTileWidget(
                            icon: postData.value?["gender"] == "Male"
                                ? Icons.male
                                : Icons.female,
                            title: "Tutor Gender: ",
                            value: "${postData.value?["gender"]}",
                          ),

                          const SizedBox(height: 15.0),

                          const Text("Note: ", style: pageSubTitleStyle),
                          const SizedBox(height: 10.0),

                          Text(
                            postData.value?["desc"],
                            style: const TextStyle(color: Colors.blue),
                          ),
                          const SizedBox(height: 15.0),

                          // DetailsTileWidget(
                          //     icon: Icons.work,
                          //     title: "Prefered Experience: ${postData.value?["req_exp"]} years"),
                          // DetailsTileWidget(
                          //     icon: Icons.school,
                          //     title: "Prefered Qualification: ${postData.value?["qualify"]}"),
                          if (!ifPurchased.value) ...[
                            DetailsColorTileWidget(
                              icon: Icons.wallet,
                              title: "Coins needed: ",
                              value: "${postData.value?["req_coins"]}",
                            ),
                            Row(
                              children: [
                                Icon(Icons.people, color: Colors.grey.shade700),
                                const SizedBox(width: 5.0),
                                Text(
                                  "${(postData.value?["users"].length) - 1} ",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const Text(
                                  "out of ",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  "${postData.value?["max_hits"]}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const Text(
                                  " Responded",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ],

                          if (ifPurchased.value ||
                              AuthControllers.isAdmin()) ...[
                            const SizedBox(height: 20.0),
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffffecce),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DetailsColorTileWidget(
                                        icon: Icons.person,
                                        title: "Contact name: ",
                                        value: "${postData.value?["name"]}",
                                      ),
                                      InkWell(
                                        onTap: () {
                                          openUrl(
                                              "tel:${postData.value?["phone"]}");
                                        },
                                        child: DetailsColorTileWidget(
                                          icon: Icons.phone,
                                          title: "Contact number: ",
                                          value: "${postData.value?["phone"]}",
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          openUrl(
                                              "mailto:${postData.value?["email"]}");
                                        },
                                        child: DetailsColorTileWidget(
                                          icon: Icons.email,
                                          title: "Contact email: ",
                                          value: "${postData.value?["email"]}",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (AuthControllers.isAdmin())
                                  IconButton(
                                      onPressed: () async {
                                        Uri? link = await getLink();
                                        String text =
                                            """VIP Home tutors post ID: ${postData.value?["id"]},
--------------------
Contact Name : ${postData.value?["name"]},
Contact Number : ${postData.value?["phone"]},
Contact Email : ${postData.value?["email"]}
--------------------
Post Link : $link,""";
                                        Share.share(text);
                                      },
                                      icon: const Icon(Icons.share))
                              ],
                            ),
                          ],

                          if (AuthControllers.isAdmin()) ...[
                            const SizedBox(height: 25.0),
                            TabBar(
                              onTap: (int index) {
                                selectedIndex.value = index;
                                tabController.animateTo(index);
                              },
                              unselectedLabelColor: Colors.black,
                              labelColor: Colors.red,
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.connect_without_contact),
                                  text: "Matched",
                                ),
                                Tab(
                                  icon: Icon(Icons.people),
                                  text: "Collected",
                                ),
                              ],
                              controller: tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                            ),
                            IndexedStack(
                              index: selectedIndex.value,
                              children: <Widget>[
                                Visibility(
                                  maintainState: true,
                                  visible: selectedIndex.value == 0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 15.0),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                            "Search Nearby Leads in Radius of [${radius.value.round()} Kms]",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Slider(
                                          label: "${radius.value.round()} Kms",
                                          min: 1,
                                          max: 10,
                                          divisions: 4,
                                          value: radius.value,
                                          onChanged: (val) {
                                            radius.value = val;
                                          }),
                                      MatchedUsers(
                                          postData: GetMatchedUsersApiModel(
                                              data: postData.value!,
                                              radius: radius.value)),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  maintainState: true,
                                  visible: selectedIndex.value == 1,
                                  child: CollectedUser(data: postData.value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 75.0),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!ifPurchased.value &&
                      !((postData.value?["users"].length - 1) >=
                          int.parse(postData.value?["max_hits"])) &&
                      !AuthControllers.isAdmin()) ...[
                    const SizedBox(height: 15.0),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              FirebaseAuth auth = FirebaseAuth.instance;
                              Map<String, dynamic> postBody = {
                                "uid": auth.currentUser?.uid,
                                "mobile": auth.currentUser?.phoneNumber,
                                "post_id": postId.value,
                                "post_no": postData.value?["id"],
                                "post_desc": postData.value?["desc"],
                                "createdOn": FieldValue.serverTimestamp()
                              };
                              Utils.loading();

                              await ProfileController.createWalletHit(
                                  postBody: postBody);
                              EasyLoading.dismiss();

                              context.push(AppRoutes.walletScreen);
                            },
                            child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text(
                                    "Upgrade Wallet",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                                  ),
                                )),
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if ((postData.value?["users"].length - 1) <
                                  int.parse(postData.value?["max_hits"])) {
                                Utils.loading();
                                var profileData = await ProfileController()
                                    .fetchProfileData(
                                        FirebaseAuth.instance.currentUser?.uid);
                                log(postId.value);
                                if (profileData?["wallet_balance"] >=
                                    int.parse(postData.value?["req_coins"])) {
                                  UserControllers.addUidIntoPost(
                                      postId: postId.value);
                                  await ProfileController.updateProfile(
                                      profileBody: {
                                        "wallet_balance":
                                            (profileData?["wallet_balance"] -
                                                int.parse(postData
                                                    .value?["req_coins"]))
                                      });
                                  User? user =
                                      FirebaseAuth.instance.currentUser;

                                  Map<String, dynamic> orderData = {
                                    "uid": user!.uid,
                                    "phone": user.phoneNumber,
                                    "post_id": postData.value?["id"],
                                    "req_coins": postData.value?["req_coins"],
                                    "wallet_balance":
                                        profileData?["wallet_balance"],
                                    "balance_left":
                                        (profileData?["wallet_balance"] -
                                            int.parse(
                                                postData.value?["req_coins"])),
                                    "createdOn": FieldValue.serverTimestamp()
                                  };
                                  await UserControllers.addToOrders(orderData);
                                  EasyLoading.dismiss();

                                  ref.refresh(profileDataProvider(
                                      FirebaseAuth.instance.currentUser?.uid));
                                  ifPurchased.value = true;
                                } else {
                                  EasyLoading.showError(
                                      "Please upgrade your wallet");
                                  EasyLoading.dismiss();
                                }
                              }
                            },
                            child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text(
                                    "Show Contact",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!AuthControllers.isAdmin()) ...[
                    const SizedBox(height: 15.0),
                    TextColoredButton(
                        onTap: () {
                          openUrl(websiteUrl);
                        },
                        lable: "Connect VIP Tutors Bureau"),
                  ]
                ],
              ),
            )),
            appBar: AppBar(
              title: Text(
                formatWithMonthNameTime
                    .format(postData.value?["createdOn"].toDate()),
              ),
              actions: [
                IconButton(
                    onPressed: () async {
                      Uri? link = await getLink();
                      Share.share(link.toString());
                    },
                    icon: const Icon(Icons.share))
              ],
            ),
            floatingActionButton: AuthControllers.isAdmin()
                ? SpeedDial(
                    icon: Icons.more_horiz,
                    children: [
                      SpeedDialChild(
                          label: "Delete",
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.delete),
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ClearDataWidget(
                                      onSubmit: () async {
                                        Utils.loading();
                                        await AdminControllers.deleteLead(
                                            postId: postId.value);
                                        EasyLoading.dismiss();
                                        Future.delayed(Duration.zero)
                                            .then((value) {
                                          context.pop();
                                        });
                                      },
                                      title: "Are you sure?",
                                      desc:
                                          "You want to delete delete this post?");
                                });
                          }),
                      SpeedDialChild(
                          label: "Edit",
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.edit),
                          onTap: () async {
                            var editData = EditPostModel(id: id, data: data);
                            context.push(AppRoutes.addNewLead, extra: editData);
                          }),
                      SpeedDialChild(
                          label: "Repost",
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.arrow_upward),
                          onTap: () async {
                            Utils.loading();
                            int lastLeadNo =
                                await AdminControllers.lastPostId();
                            var newPostBody = postData.value;
                            newPostBody?["id"] = lastLeadNo + 1;
                            newPostBody?["createdOn"] =
                                FieldValue.serverTimestamp();
                            newPostBody?['users'] = FieldValue.arrayUnion([""]);
                            await AdminControllers.createLeads(
                                postBody: newPostBody!);
                            EasyLoading.dismiss();
                            Future.delayed(Duration.zero).then((value) {
                              context.pop();
                            });
                          })
                    ],
                  )
                : null);
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
          Expanded(
            child: Text(
              value ?? "",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

class TextColoredButton extends StatelessWidget {
  final void Function()? onTap;
  final String lable;
  const TextColoredButton({super.key, this.onTap, required this.lable});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.lightBlue, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              lable,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
