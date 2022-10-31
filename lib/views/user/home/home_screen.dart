import 'package:app/controllers/routes.dart';
import 'package:app/views/posts/posts_list.dart';
import 'package:app/views/widgets/error_widget_screen.dart';
import 'package:app/views/widgets/loading_widget_screen.dart';
import 'package:app/views/widgets/user_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/profile_provider.dart';
import '../history_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    PostListScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProvider = ref.watch(profileDataProvider);
    final cityName = ref.watch(cityNameProvider.state);
    final selectedIndex = useState(0);
    return profileProvider.when(loading: () {
      return const LoadingWidgetScreen();
    }, error: (error, stackTrace) {
      return const ErrorWidgetScreen();
    }, data: (data) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        cityName.state = data?["city"];
      });
      return Scaffold(
        body: SafeArea(child: _widgetOptions.elementAt(selectedIndex.value)),
        appBar: AppBar(
          title: const Text("Posts"),
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
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          currentIndex: selectedIndex.value,
          selectedItemColor: Colors.amber[800],
          onTap: (int index) {
            selectedIndex.value = index;
          },
        ),
      );
    });
  }
}
