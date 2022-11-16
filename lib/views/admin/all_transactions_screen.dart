import 'package:app/controllers/profile_controllers.dart';
import 'package:app/views/user/wallet/transactions_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final statusLIst = ["All", "true", "false"];

class AllTransactionsScreen extends HookConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = useState("All");
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
      body: StreamBuilder(
          stream: ProfileController.fetchAllTransactions(
              true, limitCount.value, selectedStatus.value),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(child: Text('No data'));
              case ConnectionState.waiting:
                return const Center(child: Text('Awaiting...'));
              case ConnectionState.active:
                return transactionListWidget(
                  context,
                  controller: scrollController,
                  data: snapshot.data?.docs,
                  isAdmin: true,
                );

              case ConnectionState.done:
                return transactionListWidget(
                  context,
                  controller: scrollController,
                  data: snapshot.data?.docs,
                  isAdmin: true,
                );
            }
          }),
      appBar: AppBar(
        title: const Text("All Transactions"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(statusLIst[index]),
                        trailing: selectedStatus.value == statusLIst[index]
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          selectedStatus.value = statusLIst[index];
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              });
        },
        child: const Icon(Icons.filter_alt),
      ),
    );
  }
}
