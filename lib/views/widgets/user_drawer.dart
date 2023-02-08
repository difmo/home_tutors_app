import 'dart:io';

import 'package:app/controllers/profile_controllers.dart';
import 'package:app/controllers/statics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/routes.dart';
import '../../controllers/utils.dart';
import 'round_alert_box.dart';

class UserDrawerWidget extends StatelessWidget {
  final Map<dynamic, dynamic>? profileData;
  const UserDrawerWidget({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileData?["photoUrl"].isEmpty
                          ? const CircleAvatar(
                              radius: 30.0,
                              backgroundImage: AssetImage(
                                  'assets/images/placeholder_user.jpeg'))
                          : CircleAvatar(
                              radius: 30.0,
                              backgroundImage:
                                  NetworkImage(profileData?["photoUrl"])),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          profileData?["name"].isEmpty
                              ? 'User Name'
                              : profileData?["name"],
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    profileData?["locality"] +
                        ", " +
                        profileData?["city"] +
                        ", " +
                        profileData?["state"],
                  ),
                  const SizedBox(height: 10.0),
                  if (!Platform.isIOS)
                    InkWell(
                      onTap: () {
                        openUrl(websiteUrl);
                      },
                      child: Text(
                        "For more details visit our website : www.viptutors.in",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  const SizedBox(height: 10.0),
                  const Divider(),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () async {
                context.push(AppRoutes.teacherProfile);
              },
            ),
            if (!Platform.isIOS) ...[
              ListTile(
                leading: const Icon(Icons.wallet),
                title: const Text("Wallet"),
                onTap: () {
                  context.push(AppRoutes.walletScreen);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text("Wallet History"),
                onTap: () {
                  context.push(AppRoutes.walletHistory);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.rule),
              title: const Text("Rules"),
              onTap: () {
                context.push(AppRoutes.rulesScreen);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () {
                context.push(AppRoutes.feedbackScreen);
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.email),
            //   title: const Text("Report mail"),
            //   onTap: () {
            //     openUrl("mailto:$adminContactMail");
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.rate_review_sharp),
              title: const Text("Rate us"),
              onTap: () {
                openUrl(
                    'https://play.google.com/store/apps/details?id=com.viptutors.app');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share app"),
              onTap: () {
                Share.share(
                    'check out VIP home tutors https://play.google.com/store/apps/details?id=com.viptutors.app');
              },
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Connected Apps'),
              onTap: () {
                context.push(AppRoutes.connectedApps);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text("Terms & Conditions"),
              onTap: () {
                openUrl("https://www.viptutors.in/terms.php");
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text("About us"),
              onTap: () {
                context.push(AppRoutes.aboutUsScreen);
              },
            ),

            if (Platform.isIOS)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete account"),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const RoundedAlertBox();
                      });
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await ProfileController.logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
