import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/utils.dart';
import '../../providers/admin_providers.dart';

class PostListScreen extends HookConsumerWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPosts = ref.watch(allPostsDataProvider);

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
                onTap: () {},
                leading: Text(
                  "${index + 1}.",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(item?["title"] ?? "Title"),
                subtitle: Text(
                    formatWithMonthName.format(item!["createdOn"].toDate())),
                trailing:
                    const Icon(Icons.keyboard_double_arrow_right_outlined),
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
          ref.refresh(allPostsDataProvider);
        },
      ),
    );
  }
}
