import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/profile_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(profileDataProvider).when(loading: () {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }, error: (error, stackTrace) {
      return Scaffold(
        body: Center(
          child: Text(error.toString()),
        ),
      );
    }, data: (data) {
      return Scaffold(
        body: SafeArea(
            // ignore: sort_child_properties_last
            child: ListView.separated(
                itemCount: 30,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text("${index + 1}."),
                    title: const Text('History home tutor needed'),
                    subtitle: const Text(
                        'Chapman 711-2880 Nulla St. Mankato Mississippi 96522'),
                    trailing: const Icon(Icons.navigate_next_outlined),
                  );
                })),
        appBar: AppBar(
          title: const Text("Home"),
          centerTitle: false,
          actions: [
            TextButton(
                onPressed: () {},
                child: const Text(
                  "🪙 598",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  data?["photoUrl"].isEmpty
                      ? const CircleAvatar(
                          radius: 30.0,
                          backgroundImage:
                              AssetImage('assets/placeholder_user.jpeg'))
                      : CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(data?["photoUrl"])),
                  const SizedBox(height: 10.0),
                  Text(
                    data?["name"].isEmpty ? 'User Name' : data?["name"],
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    data?["locality"] +
                        ", " +
                        data?["city"] +
                        ", " +
                        data?["state"],
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
                onTap: () async {},
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
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change password"),
                onTap: () async {
                  Utils.loading();
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: data?["email"]);
                  EasyLoading.dismiss();
                  EasyLoading.showInfo(
                      "Password change link has been sent to your email ID");
                },
              ),
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
        ),
      );
    });
  }
}
