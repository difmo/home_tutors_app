import 'package:app/providers/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/utils.dart';

class WalletHistory extends HookConsumerWidget {
  const WalletHistory({super.key});

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
              var item = data?[index].data();
              return ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(
                  "- ${item?["req_coins"]} Coins",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "Posted on: ${formatWithMonthNameTime.format(item?["createdOn"].toDate())}"),
                trailing: Text("Post ID: ${item?["post_id"]}"),
              );
            });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchOrders = ref.watch(fetchOrdersProvider);
    return Scaffold(
      body: SafeArea(
          child: fetchOrders.when(
        data: (data) {
          return postListWidget(context, data);
        },
        error: (error, stackTrace) {
          return const Center(
              child: Text("Someting went wrong, contact support",
                  textAlign: TextAlign.center));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      )),
      appBar: AppBar(
        title: const Text("Wallet History"),
      ),
    );
  }
}
