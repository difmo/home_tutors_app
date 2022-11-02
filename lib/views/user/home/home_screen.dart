import 'package:app/controllers/routes.dart';
import 'package:app/views/auth/profile_verification_screen.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:app/views/widgets/error_widget_screen.dart';
import 'package:app/views/widgets/loading_widget_screen.dart';
import 'package:app/views/widgets/user_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/profile_provider.dart';
import '../history_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  TabBar get tabBarList => const TabBar(
        labelColor: Colors.black,
        tabs: [
          Tab(
            text: "ENQUIRY",
          ),
          Tab(
            text: "CONTACTED",
          ),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(profileDataProvider);
    final stateName = ref.watch(stateNameProvider.state);
    return profileProvider.when(loading: () {
      return const LoadingWidgetScreen();
    }, error: (error, stackTrace) {
      return const ErrorWidgetScreen();
    }, data: (data) {
      if (data != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          stateName.state = data["state"];
        });
      }

      return data?["status"] == 1
          ? DefaultTabController(
              length: 2,
              child: Scaffold(
                body: const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: TabBarView(children: [
                    PostListScreen(),
                    HistoryScreen(),
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
              ),
            )
          : ProfileVerificationScreen(
              email: data?['email'],
            );
    });
  }
}
