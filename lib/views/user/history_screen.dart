import 'package:app/controllers/user_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/routes.dart';
import '../../controllers/utils.dart';
import '../constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                  context.pushNamed(AppRoutes.postDetails,
                      extra: item.data(), params: {"id": item.id});
                },
                leading: Text(
                  "${index + 1}.",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Row(
                  children: [
                    const Text(
                      "Lead No: ",
                      style: pageSubTitleStyle,
                    ),
                    Text(
                      "${item?["id"]}",
                      style: pageSubTitleStyle.copyWith(color: Colors.red),
                    ),
                  ],
                ),
                subtitle: Text(
                    formatWithMonthName.format(item!["createdOn"].toDate())),
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
    );
  }
}
