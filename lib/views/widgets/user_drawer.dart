import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/routes.dart';

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
            title: const Text("Wallet & History"),
            onTap: () {
              context.push(AppRoutes.walletScreen);
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Contact support"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text("Terms & Conditions"),
            onTap: () {},
          ),
          // ListTile(
          //   leading: const Icon(Icons.lock),
          //   title: const Text("Change password"),
          //   onTap: () async {
          //     Utils.loading();
          //     await FirebaseAuth.instance
          //         .sendPasswordResetEmail(email: profileData?["email"]);
          //     EasyLoading.dismiss();
          //     EasyLoading.showInfo(
          //         "Password change link has been sent to your email ID");
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              FirebaseAuth.instance.signOut();
              context.go(AppRoutes.login);
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
