import 'package:app/views/user/wallet/transactions_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/profile_provider.dart';

class AllTransactionsScreen extends HookConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsProvider = ref.watch(alTransactionsProvider(true));

    return Scaffold(
      body: transactionsProvider.when(
        data: (listData) {
          return TransactionsListScreen(
            data: listData,
            isAdmin: true,
          );
        },
        error: (error, stackTrace) {
          return const Center(
            child: Text("Something went wrong"),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      appBar: AppBar(
        title: const Text("All Transactions"),
      ),
    );
  }
}
