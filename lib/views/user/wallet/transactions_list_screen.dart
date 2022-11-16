import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../controllers/utils.dart';

Widget transactionListWidget(BuildContext context,
    {List<QueryDocumentSnapshot<Map<String, dynamic>>>? data,
    bool isAdmin = false,
    required ScrollController controller}) {
  return checkEmpty(data)
      ? const Center(
          child: Text('No transactions available'),
        )
      : isAdmin
          ? ListView.builder(
              key: const PageStorageKey<String>('transPosition'),
              controller: controller,
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
              controller: controller,
              key: const PageStorageKey<String>('transPosition2'),
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
                  subtitle: Text(formatWithMonthNameTime.format(
                      item?["createdOn"] == null
                          ? DateTime.now()
                          : item?["createdOn"].toDate())),
                );
              });
}
