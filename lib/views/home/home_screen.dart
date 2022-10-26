import 'package:app/controllers/routes.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:app/views/widgets/error_widget_screen.dart';
import 'package:app/views/widgets/loading_widget_screen.dart';
import 'package:app/views/widgets/user_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/profile_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(profileDataProvider).when(loading: () {
      return const LoadingWidgetScreen();
    }, error: (error, stackTrace) {
      return const ErrorWidgetScreen();
    }, data: (data) {
      return Scaffold(
          body: const SafeArea(child: PostListScreen()),
          appBar: AppBar(
            title: const Text("Home"),
            centerTitle: false,
            actions: [
              TextButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.walletScreen);
                  },
                  icon: const Icon(Icons.wallet, color: Colors.yellow),
                  label: Text(
                    (data?["wallet_balance"] ?? 0).toString(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          drawer: UserDrawerWidget(
            profileData: data,
          ));
    });
  }
}
