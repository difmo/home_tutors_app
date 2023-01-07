import 'dart:io';

import 'package:app/controllers/profile_controllers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../controllers/routes.dart';
import '../../controllers/utils.dart';
import 'round_alert_box.dart';

class UserDrawerWidget extends StatelessWidget {
  final Map<dynamic, dynamic>? profileData;
  const UserDrawerWidget({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileData?["photoUrl"].isEmpty
                  ? const CircleAvatar(
                      radius: 30.0,
                      backgroundImage:
                          AssetImage('assets/images/placeholder_user.jpeg'))
                  : CircleAvatar(
                      radius: 30.0,
                      backgroundImage: NetworkImage(profileData?["photoUrl"])),
              const SizedBox(height: 10.0),
              Text(
                profileData?["name"].isEmpty
                    ? 'User Name'
                    : profileData?["name"],
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                profileData?["locality"] +
                    ", " +
                    profileData?["city"] +
                    ", " +
                    profileData?["state"],
              ),
            ],
          )),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () async {
              context.push(AppRoutes.teacherProfile);
            },
          ),
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
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Report mail"),
            onTap: () {
              openUrl("mailto:$adminContactMail");
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
            leading: const Icon(Icons.share),
            title: const Text("Share app"),
            onTap: () {
              Share.share(
                  'check out VIP home tutors https://play.google.com/store/apps/details?id=com.viptutors.app');
            },
          ),
          ListTile(
            leading: const Icon(Icons.rate_review_sharp),
            title: const Text("Rate us"),
            onTap: () {
              launchUrlString(
                  'https://play.google.com/store/apps/details?id=com.viptutors.app',
                  mode: LaunchMode.externalNonBrowserApplication);
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
          const SizedBox(height: 10.0),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'App version: v0.0.1',
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
