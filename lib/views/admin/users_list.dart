import 'package:app/controllers/admin/admin_controllers.dart';
import 'package:app/controllers/routes.dart';
import 'package:app/views/admin/widgets/clear_data_confirm_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/statics.dart';
import '../../controllers/utils.dart';
import '../../providers/profile_provider.dart';
import 'user_details_screen.dart';

class UserStatusModel {
  String status;
  int index;
  UserStatusModel({required this.status, required this.index});
}

class UsersListScreen extends HookConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = useState(10);
    final noFIlter = useState(true);
    final filterKey = useState("");
    final filterValue = useState<dynamic>("");

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
              stream: AdminControllers.fetchAllUsers(limitCount.value,
                  noFIlter: noFIlter.value,
                  filterKey: filterKey.value,
                  filterValue: filterValue.value),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');

                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const Center(child: Text('No data'));
                  case ConnectionState.waiting:
                    return const Center(child: Text('Awaiting...'));
                  case ConnectionState.active:
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
                              context.push(AppRoutes.userDetails, extra: item);
                            },
                            leading:
                                const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(item?["name"] ?? "Name"),
                            subtitle: Text(formatWithMonthName.format(
                                item?["createdOn"] == null
                                    ? DateTime.now()
                                    : item?["createdOn"].toDate())),
                            trailing: item?["status"] == 1
                                ? const Icon(Icons.verified, color: Colors.blue)
                                : item?["status"] == 0
                                    ? const Icon(Icons.access_time,
                                        color: Colors.grey)
                                    : const Icon(Icons.close,
                                        color: Colors.red),
                          );
                        });
                }
              }),
        ),
        appBar: AppBar(
          title: TextField(
            decoration: const InputDecoration(
                hintText: "Type Name or number", border: InputBorder.none),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              context.push(AppRoutes.searchResults, extra: value);
            },
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  Utils.loading(msg: "Downloading...");
                  await AdminControllers.getUsersList();
                  EasyLoading.dismiss();
                },
                icon: const Icon(Icons.file_download))
          ],
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.more_horiz,
          children: [
            SpeedDialChild(
                label: "State Filter",
                backgroundColor: Colors.blue,
                child: const Icon(Icons.filter_alt),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  itemCount: stateList.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(stateList[index]),
                                      trailing: ref
                                                  .watch(selectedStateProvider
                                                      .notifier)
                                                  .state ==
                                              stateList[index]
                                          ? const Icon(Icons.check)
                                          : null,
                                      onTap: () {
                                        ref
                                            .watch(
                                                selectedStateProvider.notifier)
                                            .state = stateList[index];
                                        filterKey.value = "state";
                                        filterValue.value = stateList[index];
                                        noFIlter.value = false;
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref
                                      .watch(selectedStateProvider.notifier)
                                      .state = 'All';
                                  selectedStatus.value = 10;
                                  filterKey.value = "";
                                  filterValue.value = "";
                                  noFIlter.value = true;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blue),
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'All',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (ref
                                              .watch(selectedStateProvider
                                                  .notifier)
                                              .state ==
                                          "All") ...[
                                        const SizedBox(width: 10.0),
                                        const Icon(Icons.check,
                                            color: Colors.white),
                                      ]
                                    ],
                                  )),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                }),
            SpeedDialChild(
                label: "Status Filter",
                backgroundColor: Colors.blue,
                child: const Icon(Icons.filter_alt),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  itemCount: profileStatusList.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title:
                                          Text(profileStatusList[index].title),
                                      trailing: selectedStatus.value ==
                                              profileStatusList[index].status
                                          ? const Icon(Icons.check)
                                          : null,
                                      onTap: () {
                                        selectedStatus.value =
                                            profileStatusList[index].status;
                                        filterKey.value = "status";
                                        filterValue.value =
                                            selectedStatus.value;
                                        noFIlter.value = false;
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  selectedStatus.value = 10;
                                  filterKey.value = "";
                                  filterValue.value = "";
                                  noFIlter.value = true;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blue),
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'All',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (selectedStatus.value == 10) ...[
                                        const SizedBox(width: 10.0),
                                        const Icon(Icons.check,
                                            color: Colors.white),
                                      ]
                                    ],
                                  )),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                }),
            SpeedDialChild(
                label: "Clear Database",
                backgroundColor: Colors.red,
                child: const Icon(Icons.cleaning_services_rounded),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ClearDataWidget(
                          onSubmit: () async {
                            Utils.loading();
                            await AdminControllers.clearDeclinedUsers();
                            EasyLoading.showSuccess("Database cleared");
                            EasyLoading.dismiss();
                            Navigator.pop(context);
                          },
                          title: "Are you sure?",
                          desc:
                              "You want to sure to delete all rejected users?");
                    },
                  );
                })
          ],
        ));
  }
}
