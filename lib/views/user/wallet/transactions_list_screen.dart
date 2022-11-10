import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../controllers/utils.dart';

class TransactionsListScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>>? data;
  final bool isAdmin;
  const TransactionsListScreen({super.key, this.data, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return checkEmpty(data)
        ? const Center(
            child: Text('No transactions available'),
          )
        : isAdmin
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: data?.length,
                itemBuilder: (context, index) {
                  var item = data?[index];
                  return ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text(
                        "₹ ${item?["amount"]} -- ${formatWithMonthNameTime.format(item?["createdOn"].toDate() ?? DateTime.now())}"),
                    trailing: item?["status"]
                        ? const Icon(Icons.check_circle_rounded,
                            color: Colors.green)
                        : const Icon(Icons.error_outlined, color: Colors.red),
                    subtitle: Text("${item?["phone"]}"),
                  );
                })
            : ListView.builder(
                shrinkWrap: true,
                itemCount: data?.length,
                itemBuilder: (context, index) {
                  var item = data?[index];
                  return ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text("₹ ${item?["amount"]}"),
                    trailing: item?["status"]
                        ? const Icon(Icons.check_circle_rounded,
                            color: Colors.green)
                        : const Icon(Icons.error_outlined, color: Colors.red),
                    subtitle: Text(formatWithMonthNameTime
                        .format(item?["createdOn"].toDate() ?? DateTime.now())),
                  );
                });
  }
}
