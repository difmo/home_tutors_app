import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:app/views/constants.dart';
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
        : ListView.builder(
            itemCount: data?.length ?? 0,
            itemBuilder: (context, index) {
              var item = data?[index];
              return InkWell(
                onTap: () {
                  context.push(AppRoutes.postDetails, extra: item);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 7,
                            spreadRadius: 5,
                            color: Colors.grey.shade300)
                      ]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Lead No: ",
                                style: pageSubTitleStyle,
                              ),
                              Text(
                                "${item?["id"]}",
                                style: pageSubTitleStyle.copyWith(
                                    color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.class_,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 5.0),
                              Text("Class: ₹${item?["class"]}"),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.school,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 5.0),
                              Text("Subject: ₹${item?["subject"]}"),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 5.0),
                              Text(item?["locality"]),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.switch_video_outlined,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 5.0),
                              Text("Mode: ${item?["mode"]} -- "),
                              const Text(
                                "(Read more)",
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          )
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatWithMonthName
                              .format(item?["createdOn"].toDate())),
                          const SizedBox(height: 25.0),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "${(item?["users"].length) - 1}/${item?["max_hits"]}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          const Text("Responded"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityName = ref.watch(cityNameProvider);
    return Scaffold(
      body: StreamBuilder(
          stream: AuthControllers.isAdmin()
              ? AdminControllers.fetchAllPosts()
              : UserControllers.fetchAllPosts(cityName),
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
