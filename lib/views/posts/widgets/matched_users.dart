import 'package:app/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/routes.dart';

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
                Future.delayed(Duration.zero).then((value) {
                  context.push(AppRoutes.userDetails, extra: item);
                });
              },
              leading: const Icon(Icons.person),
              title: Text(item?["phone"]),
            );
          });
    }, error: (error, stackTrace) {
      return Text(error.toString());
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }
}
