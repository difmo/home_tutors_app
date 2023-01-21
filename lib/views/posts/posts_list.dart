import 'dart:developer';

import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/views/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/utils.dart';

class PostListScreen extends HookConsumerWidget {
  final bool nearBy;
  final PostLocationFilterModel? filterData;
  const PostListScreen(this.nearBy, {super.key, this.filterData});

  Widget postListWidget(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>? data,
      ScrollController controller) {
    return checkEmpty(data)
        ? Column(
            children: [
              const Center(
                child: Text("No post available"),
              ),
              if (nearBy)
                const Text("Please try increasing radius for more results",
                    textAlign: TextAlign.center)
            ],
          )
        : ListView.builder(
            controller: controller,
            key: const PageStorageKey<String>('postPosition'),
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 100.0),
            itemCount: data?.length ?? 0,
            itemBuilder: (context, index) {
              var item = data?[index].data();
              return item == null
                  ? const SizedBox.shrink()
                  : checkContains(int.parse(item["max_hits"]), item["users"])
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            context.pushNamed(AppRoutes.postDetails,
                                extra: item, params: {"id": data![index].id});
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Lead No: ",
                                          style: pageSubTitleStyle,
                                        ),
                                        Text(
                                          "${item["id"]}",
                                          style: pageSubTitleStyle.copyWith(
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    Text(formatWithMonthName.format(
                                        item["createdOn"] == null
                                            ? DateTime.now()
                                            : item["createdOn"].toDate())),
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
                                    Expanded(
                                      child: Text(
                                          "Class: ${item["class"]} ${item["board"] ?? ""}"),
                                    ),
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
                                    Expanded(
                                        child: Text(
                                            "Subject: ${item["subject"]}")),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_city,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 5.0),
                                      Expanded(
                                        child: Text(
                                            "Location: ${item["locality"]}, ${item["city"]}"),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.switch_video_outlined,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 5.0),
                                          Flexible(
                                              child: Text(
                                                  "Mode: ₹${item["mode"]}")),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        "0/${((int.parse(item["max_hits"]) - (item["users"].length - 1)))}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.monetization_on,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 5.0),
                                          Flexible(
                                              child:
                                                  Text("Fee: ₹${item["fee"]}")),
                                          const Text(
                                            "(Read more)",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Text("Responded"),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
            });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final selectedState = ref.watch(selectedStateProvider);
    final scrollController = useScrollController();
    final limitCount = useState(20);
    useEffect(() {
      scrollController.addListener(() {
        if (scrollController.position.atEdge) {
          if (scrollController.position.pixels == 0) {
          } else {
            limitCount.value = limitCount.value + 20;
          }
        }
      });
      return;
    }, []);
    return StreamBuilder(
        stream: AuthControllers.isAdmin()
            ? AdminControllers.fetchAllPosts(limitCount.value)
            : UserControllers.fetchAllPosts(
                filterData: filterData,
                // selectedState == 'All' ? null : selectedState,
                limit: limitCount.value),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Center(child: Text('No data'));
            case ConnectionState.waiting:
              return const Center(child: Text('Awaiting...'));
            case ConnectionState.active:
            case ConnectionState.done:
              return postListWidget(
                  context, snapshot.data?.docs, scrollController);
          }
        });
  }
}

bool checkContains(int max, List<dynamic> data) {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool hide = false;
  if (AuthControllers.isAdmin()) {
    log(hide.toString());
    return hide;
  } else {
    for (var element in data) {
      if (element == currentUser?.phoneNumber) {
        hide = true;
        break;
      }
    }
    if ((data.length - 1) == max) {
      hide = true;
    }
  }

  return hide;
}
