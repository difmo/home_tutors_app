import 'package:app/controllers/routes.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/views/auth/profile_verification_screen.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:app/views/widgets/error_widget_screen.dart';
import 'package:app/views/widgets/loading_widget_screen.dart';
import 'package:app/views/widgets/user_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../controllers/utils.dart';
import '../../../providers/profile_provider.dart';
import '../history_screen.dart';

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({super.key});
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TabBar get tabBarList => const TabBar(
        labelColor: Colors.black,
        tabs: [
          Tab(
            text: "ENQUIRY",
            // child:
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     IconButton(
            //         onPressed: () {
            //           // showDialog(
            //           //     context: context,
            //           //     builder: (context) {
            //           //       return Dialog(
            //           //         child: Column(
            //           //           children: [
            //           //             Expanded(
            //           //               child: ListView.separated(
            //           //                 shrinkWrap: true,
            //           //                 separatorBuilder: (context, index) {
            //           //                   return const Divider();
            //           //                 },
            //           //                 itemCount: stateList.length,
            //           //                 itemBuilder: (context, index) {
            //           //                   return ListTile(
            //           //                     title: Text(stateList[index]),
            //           //                     trailing: ref
            //           //                                 .watch(
            //           //                                     selectedStateProvider
            //           //                                         .notifier)
            //           //                                 .state ==
            //           //                             stateList[index]
            //           //                         ? const Icon(Icons.check)
            //           //                         : null,
            //           //                     onTap: () {
            //           //                       ref
            //           //                           .watch(selectedStateProvider
            //           //                               .notifier)
            //           //                           .state = stateList[index];
            //           //                       Navigator.pop(context);
            //           //                     },
            //           //                   );
            //           //                 },
            //           //               ),
            //           //             ),
            //           //             InkWell(
            //           //               onTap: () {
            //           //                 ref
            //           //                     .watch(selectedStateProvider.notifier)
            //           //                     .state = 'All';
            //           //                 Navigator.pop(context);
            //           //               },
            //           //               child: Container(
            //           //                 width: double.infinity,
            //           //                 height: 50.0,
            //           //                 padding: const EdgeInsets.all(10),
            //           //                 margin: const EdgeInsets.all(10),
            //           //                 decoration: BoxDecoration(
            //           //                     borderRadius:
            //           //                         BorderRadius.circular(20),
            //           //                     color: Colors.blue),
            //           //                 child: Center(
            //           //                     child: Row(
            //           //                   mainAxisAlignment:
            //           //                       MainAxisAlignment.center,
            //           //                   children: [
            //           //                     const Text(
            //           //                       'All',
            //           //                       style: TextStyle(
            //           //                           color: Colors.white,
            //           //                           fontSize: 25.0,
            //           //                           fontWeight: FontWeight.bold),
            //           //                     ),
            //           //                     if (ref
            //           //                             .watch(selectedStateProvider
            //           //                                 .notifier)
            //           //                             .state ==
            //           //                         "All") ...[
            //           //                       const SizedBox(width: 10.0),
            //           //                       const Icon(Icons.check,
            //           //                           color: Colors.white),
            //           //                     ]
            //           //                   ],
            //           //                 )),
            //           //               ),
            //           //             ),
            //           //           ],
            //           //         ),
            //           //       );
            //           //     });
            //         },
            //         icon: const Icon(
            //           Icons.location_pin,
            //           color: Colors.green,
            //         )),
            //     const SizedBox(width: 5.0),
            //     const
            //     Text("ENQUIRY"),
            //   ],
            // ),
          ),
          Tab(
            text: "CONTACTED",
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final profileProvider =
        ref.watch(profileDataProvider(FirebaseAuth.instance.currentUser?.uid));
    final filterData = useState<PostLocationFilterModel?>(null);
    // final firstTime = useState(true);

    return profileProvider.when(loading: () {
      return const LoadingWidgetScreen();
    }, error: (error, stackTrace) {
      return const ErrorWidgetScreen();
    }, data: (data) {
      Utils.subscribeToTopic(data?["state"] == null
          ? "all"
          : data?["state"].replaceAll(' ', '').toLowerCase());

      // if (data != null) {
      //   if (data["location"] != null) {
      //     SchedulerBinding.instance.addPostFrameCallback((_) {
      //       if (firstTime.value) {
      //         filterData.value = PostLocationFilterModel(
      //             geoPoint: data["location"], radius: 20.0);
      //         firstTime.value = !firstTime.value;
      //       }
      //     });
      //   }
      // }

      return data?["status"] == 1
          ? DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TabBarView(children: [
                    PostListScreen(filterData: filterData.value),
                    const HistoryScreen(),
                  ]),
                ),
                appBar: AppBar(
                  titleTextStyle: const TextStyle(fontSize: 14.0),
                  leading: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CircleAvatar(
                        backgroundImage: AssetImage("assets/logo.png")),
                  ),
                  centerTitle: true,
                  title: Row(
                    children: [
                      const Text("VIP Home Tutors"),
                      const SizedBox(width: 10.0),
                      TextButton(
                          onPressed: () {
                            context.push(AppRoutes.walletScreen);
                          },
                          child: Text(
                            "Upgrade ${data?["wallet_balance"] ?? 0}",
                            style: const TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: tabBarList.preferredSize,
                    child: ColoredBox(
                      color: Colors.grey.shade100,
                      child: tabBarList,
                    ),
                  ),
                ),
                endDrawer: UserDrawerWidget(
                  profileData: data,
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    if (data?["location"] != null) {
                      if (filterData.value != null) {
                        filterData.value = null;
                      } else {
                        filterData.value = PostLocationFilterModel(
                            geoPoint: data?["location"], radius: 20.0);
                      }
                    } else {
                      EasyLoading.showInfo(
                          'Please update your Locality to enable Nearby service');
                      context.push(AppRoutes.teacherProfile);
                    }
                  },
                  backgroundColor:
                      filterData.value != null ? Colors.green : Colors.grey,
                  icon: const Icon(Icons.location_pin),
                  label: const Text("Nearby"),
                ),
              ),
            )
          : ProfileVerificationScreen(
              email: data?['email'],
            );
    });
  }
}
