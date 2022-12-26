import 'package:app/views/admin/widgets/send_notification_widget.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/profile_controllers.dart';
import '../../controllers/routes.dart';

class AdminHomeScreen extends HookConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const SafeArea(child: PostListScreen()),
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: false,
        actions: [
          TextButton.icon(
              onPressed: () {
                context.push(AppRoutes.addNewLead);
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: const Text(
                'New post',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 30.0,
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white)),
                    Icon(
                      Icons.verified,
                      color: Colors.blue.shade900,
                    )
                  ],
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ??
                          "admin@site.com",
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            )),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle_sharp),
              title: const Text('Users'),
              onTap: () {
                context.push(AppRoutes.allUsersList);
              },
            ),
            ListTile(
              leading: const Icon(Icons.balance),
              title: const Text('Transaction'),
              onTap: () {
                context.push(AppRoutes.allTransactions);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tap_and_play),
              title: const Text('Wallet Hits'),
              onTap: () {
                context.push(AppRoutes.walletHits);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notification_add),
              title: const Text('Send Notification'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SendNotificationWidget();
                    });
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await ProfileController.logout(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
