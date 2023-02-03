import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/utils.dart';
import 'admin/widgets/clear_data_confirm_widget.dart';

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(fetchNotifications);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: SafeArea(
          child: notifications.when(
        data: (data) {
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var item = data[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(10.0),
                  leading: const Icon(Icons.notifications_active),
                  title: Text(item["title"]),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10.0),
                      Linkify(
                          onOpen: (link) async {
                            openUrl(link.url);
                          },
                          text: item["body"]),
                      const SizedBox(height: 5.0),
                      Text(formatWithMonthNameTime
                          .format(item["createdOn"].toDate())),
                    ],
                  ),
                  trailing: AuthControllers.isAdmin()
                      ? IconButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ClearDataWidget(
                                      onSubmit: () async {
                                        Utils.loading();
                                        await AdminControllers
                                            .deleteNotification(item.id);
                                        EasyLoading.dismiss();
                                        ref.refresh(fetchNotifications);
                                      },
                                      title: "Are you sure?",
                                      desc:
                                          "You want to delete this notification?");
                                });
                          },
                          icon: const Icon(Icons.delete))
                      : null,
                );
              });
        },
        error: (error, stackTrace) {
          return const Center(
            child: Text("Something went wrong"),
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      )),
      floatingActionButton: AuthControllers.isAdmin()
          ? FloatingActionButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ClearDataWidget(
                          onSubmit: () async {
                            Utils.loading();
                            await AdminControllers.clearOldNotifications();
                            EasyLoading.dismiss();
                            ref.refresh(fetchNotifications);
                          },
                          title: "Are you sure?",
                          desc:
                              "You want to sure to delete all notifications older than 30 days?");
                    });
              },
              child: const Icon(Icons.cleaning_services_rounded),
            )
          : null,
    );
  }
}
