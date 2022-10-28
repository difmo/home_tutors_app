import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/utils.dart';

class PostListScreen extends HookConsumerWidget {
  const PostListScreen({super.key});

  Widget postListWidget(BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>? data) {
    return checkEmpty(data)
        ? const Center(
            child: Text("No post available"),
          )
        : ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: data?.length ?? 0,
            itemBuilder: (context, index) {
              var item = data?[index];
              return ListTile(
                onTap: () {
                  context.push(AppRoutes.postDetails, extra: item);
                },
                leading: Text(
                  "${index + 1}.",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(item?["title"] ?? "Title"),
                subtitle: Text(
                    formatWithMonthName.format(item!["createdOn"].toDate())),
                trailing: Text(
                  "0/${item["max_hits"]}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              );
            });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder(
          stream: AdminControllers.fetchAllPosts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(child: Text('No data'));
              case ConnectionState.waiting:
                return const Center(child: Text('Awaiting...'));
              case ConnectionState.active:
                return postListWidget(context, snapshot.data?.docs);

              case ConnectionState.done:
                return postListWidget(context, snapshot.data?.docs);
            }
          }),
    );
  }
}
