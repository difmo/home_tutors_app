import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/admin/widgets/clear_data_confirm_widget.dart';
import 'package:app/views/admin/widgets/send_notification_widget.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/profile_controllers.dart';
import '../../controllers/routes.dart';
import '../../controllers/statics.dart';

class AdminHomeScreen extends HookConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clearPost = useCallback(() async {
      DateTime lastDate =
          await AdminControllers.oldPostDate() ?? DateTime.now();
      if (lastDate.isBefore(DateTime.now()
          .subtract(const Duration(days: autoPostDeleteDateRange)))) {
        await AdminControllers.clearOldPosts();
      }
    }, []);
    useEffect(() {
      if (DateTime.now().hour >= 19 && DateTime.now().hour <= 21) {
        clearPost();
      }
      return;
    }, []);
    return Scaffold(
      body: const SafeArea(child: PostListScreen(false)),
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: false,
        actions: [
          TextButton.icon(
              label: const Text("Share", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () async {
                Share.share(
                    'check out VIP home tutors https://play.google.com/store/apps/details?id=com.viptutors.app');
              }),
          TextButton.icon(
              label: const Text("Add", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                context.push(AppRoutes.addNewLead);
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.cleaning_services_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ClearDataWidget(
                    onSubmit: () async {
                      Utils.loading(msg: "Please wait, cleaning database");
                      await AdminControllers.clearOldPosts();
                      EasyLoading.dismiss();
                      EasyLoading.showSuccess("Database cleared");
                      Navigator.pop(context);
                    },
                    title: "Are you sure?",
                    desc:
                        "You want to sure to delete all post older than 30 days?");
              },
            );
          }),
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
              leading: const Icon(Icons.attach_money_outlined),
              title: const Text('Amount Options'),
              onTap: () {
                context.push(AppRoutes.amountOptionsScreen);
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
