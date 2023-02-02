import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/admin/admin_controllers.dart';
import '../../../controllers/routes.dart';
import '../../../controllers/utils.dart';

class MatchedUsers extends HookConsumerWidget {
  final GetMatchedUsersApiModel postData;

  const MatchedUsers({super.key, required this.postData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final matchedUserProvider = ref.watch(matchedUsersFutureProvider(postData));
    return StreamBuilder(
        stream: AdminControllers.getMatchedUsers(postData) ,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Center(child: Text('No data'));
            case ConnectionState.waiting:
              return const Center(child: Text('Awaiting...'));
            case ConnectionState.active:
            case ConnectionState.done:
              log(snapshot.data!.length.toString());
              if(snapshot.data!.isEmpty) {
                return const Center(child: Text("No Data found"),);
              }
          List<Map<String, dynamic>> locationListUsers = [];
          List<Map<String, dynamic>> classListUsers = [];
          List<Map<String, dynamic>> subjectListUsers = [];
          for (var element in snapshot.data!) {
            locationListUsers.add(element.data() as Map<String, dynamic>);
          }
          log("Total all users ${locationListUsers.length}");

          for (var user in locationListUsers) {
            for (var userClass in user["preferedClassList"]) {
              log("Class from user $userClass");
              if (postData.data["classList"].contains(userClass)) {
                log("contains");
                classListUsers.add(user);
                break;
              }
            }
          }
          log("Class users ${classListUsers.length}");

          for (var user in classListUsers) {
            for (var userSubject in user["preferedSubjectList"]) {
              log("Subject from user $userSubject");
              if (postData.data["subjectList"].contains(userSubject)) {
                log("contains");
                subjectListUsers.add(user);
                break;
              }
            }
          }
              if(subjectListUsers.isEmpty) {
                return const Center(child: Text("No Data found"),);
              }
              return ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: subjectListUsers.length,
                          itemBuilder: (context, index) {
                            final item = subjectListUsers[index];
                            return ListTile(
                              onTap: () async {
                                Utils.loading();
                                var userData =
                                    await AdminControllers.fetchProfileData(item["phone"]);
                                EasyLoading.dismiss();
                                Future.delayed(Duration.zero).then((value) {
                                  context.push(AppRoutes.userDetails, extra: userData);
                                });
                              },
                              leading: const Icon(Icons.person),
                              trailing: IconButton(
                                  onPressed: () {
                                    openUrl("tel:${item["phone"]}");
                                  },
                                  icon: const CircleAvatar(child: Icon(Icons.call))),
                              title: Text(item["phone"]),
                              subtitle: Text(item["name"]),
                            );
                          });
          }
        });
    //   return matchedUserProvider.when(data: (data) {
    //     return ListView.builder(
    //         primary: false,
    //         shrinkWrap: true,
    //         itemCount: data.length,
    //         itemBuilder: (context, index) {
    //           final item = data[index];
    //           return ListTile(
    //             onTap: () async {
    //               Utils.loading();
    //               var userData =
    //                   await AdminControllers.fetchProfileData(item?["phone"]);
    //               EasyLoading.dismiss();
    //               Future.delayed(Duration.zero).then((value) {
    //                 context.push(AppRoutes.userDetails, extra: userData);
    //               });
    //             },
    //             leading: const Icon(Icons.person),
    //             trailing: IconButton(
    //                 onPressed: () {
    //                   openUrl("tel:${item?["phone"]}");
    //                 },
    //                 icon: const CircleAvatar(child: Icon(Icons.call))),
    //             title: Text(item?["phone"]),
    //             subtitle: Text(item?["name"]),
    //           );
    //         });
    //   }, error: (error, stackTrace) {
    //     return Text(error.toString());
    //   }, loading: () {
    //     return const Center(child: CircularProgressIndicator());
    //   });
    // }
  }
}