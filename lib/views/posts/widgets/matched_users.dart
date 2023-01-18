import 'package:app/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/admin/admin_controllers.dart';
import '../../../controllers/routes.dart';
import '../../../controllers/utils.dart';

class MatchedUsers extends HookConsumerWidget {
  final Map<String, dynamic>? postData;
  const MatchedUsers({super.key, required this.postData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchedUserProvider = ref.watch(matchedUsersFutureProvider(postData));
    return matchedUserProvider.when(data: (data) {
      return ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return ListTile(
              onTap: () async {
                Utils.loading();
                var userData =
                    await AdminControllers.fetchProfileData(item?["phone"]);
                EasyLoading.dismiss();
                Future.delayed(Duration.zero).then((value) {
                  context.push(AppRoutes.userDetails, extra: userData);
                });
              },
              leading: const Icon(Icons.person),
              trailing: IconButton(
                  onPressed: () {
                    openUrl("tel:${item?["phone"]}");
                  },
                  icon: const CircleAvatar(child: Icon(Icons.call))),
              title: Text(item?["phone"]),
              subtitle: Text(item?["name"]),
            );
          });
    }, error: (error, stackTrace) {
      return Text(error.toString());
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }
}
