import 'package:app/controllers/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/utils.dart';
import '../../providers/admin_providers.dart';

class UsersListScreen extends HookConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPosts = ref.watch(allUsersDataProvider);

    return Scaffold(
      body: allPosts.when(data: (data) {
        return ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: data?.length ?? 0,
            itemBuilder: (context, index) {
              var item = data?[index];
              return ListTile(
                onTap: () {
                  context.push(AppRoutes.userDetails, extra: item);
                },
                leading: Text(
                  "${index + 1}.",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(item?["name"] ?? "Name"),
                subtitle: Text(formatWithMonthName
                    .format(item?["createdOn"].toDate() ?? DateTime.now())),
                trailing: item?["status"] == 1
                    ? const Icon(Icons.verified, color: Colors.blue)
                    : item?["status"] == 0
                        ? const Icon(Icons.access_time, color: Colors.grey)
                        : const Icon(Icons.close, color: Colors.red),
              );
            });
      }, error: (error, stackTrace) {
        return Center(
          child: Text(error.toString()),
        );
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          ref.refresh(allUsersDataProvider);
        },
      ),
      appBar: AppBar(
        title: const Text("Users"),
      ),
    );
  }
}
