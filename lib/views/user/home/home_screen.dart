import 'package:app/controllers/routes.dart';
import 'package:app/controllers/user_controllers.dart';
import 'package:app/views/auth/profile_verification_screen.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:app/views/widgets/error_widget_screen.dart';
import 'package:app/views/widgets/loading_widget_screen.dart';
import 'package:app/views/widgets/user_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
          Tab(text: "Nearby"),
          Tab(text: "ENQUIRY"),
          Tab(text: "CONTACTED")
        ],
      );

  @override
  Widget build(BuildContext context) {
    final profileProvider =
        ref.watch(profileDataProvider(FirebaseAuth.instance.currentUser?.uid));
    final filterData = useState<PostLocationFilterModel?>(null);
    final firstTime = useState(true);
    final setState = useState(false);

    return profileProvider.when(loading: () {
      return const LoadingWidgetScreen();
    }, error: (error, stackTrace) {
      return const ErrorWidgetScreen();
    }, data: (data) {
      Utils.subscribeToTopic(data?["state"] == null
          ? "all"
          : data?["state"].replaceAll(' ', '').toLowerCase());

      if (data != null) {
        if (data["location"] != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (firstTime.value) {
              filterData.value = PostLocationFilterModel(
                  geoPoint: data["location"], radius: 10.0);
              firstTime.value = !firstTime.value;
            }
          });
        }
      }

      return data?["status"] == 1
          ? DefaultTabController(
              length: 3,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TabBarView(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: Text(
                                "Nearby Radius [${filterData.value?.radius ?? 10} Miles]",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                        Slider(
                            label: "${filterData.value?.radius ?? 10} Miles",
                            min: 10,
                            max: 50,
                            divisions: 4,
                            value: filterData.value?.radius ?? 10,
                            onChanged: (val) {
                              filterData.value!.radius = val;
                              setState.value = !setState.value;
                            }),
                        Expanded(
                            child: PostListScreen(true,
                                filterData: filterData.value)),
                      ],
                    ),
                    const PostListScreen(false),
                    const HistoryScreen()
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
                endDrawer: UserDrawerWidget(profileData: data),
              ),
            )
          : ProfileVerificationScreen(
              email: data?['email'],
            );
    });
  }
}
