import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/admin/admin_controllers.dart';
import '../../controllers/utils.dart';

class WalletHitsScreen extends HookConsumerWidget {
  const WalletHitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
            stream: AdminControllers.fetchAllWalletHits(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Center(child: Text('No data'));
                case ConnectionState.waiting:
                  return const Center(child: Text('Awaiting...'));
                case ConnectionState.active:
                  return ListView.separated(
                      key: const PageStorageKey<String>('userPosition'),
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 100.0),
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = snapshot.data?.docs[index];
                        return ListTile(
                          onTap: () {
                            openUrl("tel:${item?["mobile"]}");
                          },
                          leading:
                              const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(item?["mobile"] ?? "Phone"),
                          subtitle: Text(formatWithMonthName.format(
                              item?["createdOn"].toDate() ?? DateTime.now())),
                        );
                      });

                case ConnectionState.done:
                  return ListView.separated(
                      key: const PageStorageKey<String>('userPosition'),
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 100.0),
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = snapshot.data?.docs[index];
                        return ListTile(
                          onTap: () {
                            openUrl("tel:${item?["mobile"]}");
                          },
                          leading:
                              const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(item?["mobile"] ?? "Phone"),
                          subtitle: Text(formatWithMonthName.format(
                              item?["createdOn"].toDate() ?? DateTime.now())),
                        );
                      });
              }
            }),
      ),
      appBar: AppBar(
        title: const Text("Wallet Hits"),
      ),
    );
  }
}
