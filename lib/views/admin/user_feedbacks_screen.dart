import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/providers/admin_providers.dart';
import 'package:app/views/admin/widgets/clear_data_confirm_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/utils.dart';

class UserFeedbackScreen extends HookConsumerWidget {
  const UserFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackProviders = ref.watch(feedbacksFutureProvider);
    return Scaffold(
      body: SafeArea(
          child: feedbackProviders.when(
        data: (data) {
          return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                var item = data[index].data();
                return ListTile(
                  title: Text("#${index + 1}. ${item["title"]}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10.0),
                      Text(
                        formatWithMonthNameTime
                            .format(item["createdOn"].toDate()),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        item["phone"],
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 5.0),
                      Text(item["desc"]),
                    ],
                  ),
                  trailing: InkWell(
                      onTap: () {
                        openUrl("tel:${item["phone"]}");
                      },
                      child: const CircleAvatar(child: Icon(Icons.phone))),
                );
              });
        },
        error: (error, stackTrace) {
          return Text(error.toString());
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      )),
      appBar: AppBar(title: const Text("Feedbacks")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ClearDataWidget(
                    onSubmit: () async {
                      Utils.loading();
                      await AdminControllers.clearFeedbacks();
                      EasyLoading.dismiss();
                      ref.refresh(feedbacksFutureProvider);
                      context.pop();
                    },
                    title: "Are you sure",
                    desc: " You want to delete all feedbacks?");
              });
        },
        child: const Icon(Icons.delete),
      ),
    );
  }
}
