import 'package:app/controllers/user_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../controllers/utils.dart';

class WalletHistory extends StatelessWidget {
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
              var item = data?[index];
              return ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(
                  "- ${item?["req_coins"]} Coins",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "Posted on: ${formatWithMonthNameTime.format(item?["createdOn"].toDate())}"),
                trailing: Text("Post ID: ${item?["id"]}"),
              );
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: UserControllers.fetchPurchasedPost(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(child: Text('No data'));
              case ConnectionState.waiting:
                return const Center(child: Text('Awaiting...'));
              case ConnectionState.active:
              case ConnectionState.done:
                return postListWidget(context, snapshot.data?.docs);
            }
          }),
      appBar: AppBar(
        title: const Text("Wallet History"),
      ),
    );
  }
}
