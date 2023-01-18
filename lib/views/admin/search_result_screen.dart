import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/routes.dart';
import '../../providers/admin_providers.dart';

class SearchResuleScreen extends HookConsumerWidget {
  final String searchKey;
  const SearchResuleScreen({super.key, required this.searchKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchProvider = ref.watch(searchUserFutureProvider(searchKey));
    return Scaffold(
      body: SafeArea(
        child: searchProvider.when(
          data: (data) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                var item = data.docs[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text("${item["name"]}"),
                  subtitle: Text("${item["phone"]}"),
                  onTap: () {
                    context.push(AppRoutes.userDetails, extra: item);
                  },
                );
              },
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(error.toString()),
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text("Search Results"),
      ),
    );
  }
}
