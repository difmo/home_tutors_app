import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/profile_controllers.dart';
import '../../controllers/routes.dart';
import '../../controllers/user_controllers.dart';
import '../../controllers/utils.dart';
import '../../providers/profile_provider.dart';

class NotificationButtonWidget extends HookConsumerWidget {
  final DateTime lastSeen;
  const NotificationButtonWidget(this.lastSeen, {super.key});

  Widget countText(int count) {
    return count == 0
        ? const Icon(Icons.notifications, size: 35)
        : Badge.count(
            count: count,
            alignment: AlignmentDirectional.topStart,
            child: const Icon(Icons.notifications, size: 35),
          );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getCount =
        useCallback((List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
      int count = 0;
      for (var element in docs) {
        var item = element.data();
        DateTime.now().isAfter(lastSeen);
        if (item["createdOn"].toDate().isAfter(lastSeen)) {
          count++;
        }
      }
      return count;
    }, [lastSeen]);
    return IconButton(
        onPressed: () async {
          Utils.loading();
          await ProfileController.updateProfile(profileBody: {
            "last_seen_notifications": FieldValue.serverTimestamp()
          });
          EasyLoading.dismiss();
          ref.refresh(
              profileDataProvider(FirebaseAuth.instance.currentUser?.uid));
          context.push(AppRoutes.notifications);
        },
        icon: StreamBuilder(
            stream: UserControllers.fetchNotificationsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return countText(0);
              }
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return countText(0);
                case ConnectionState.active:
                case ConnectionState.done:
                  var count = getCount(snapshot.data?.docs ?? []);
                  return countText(count);
              }
            }));
  }
}
