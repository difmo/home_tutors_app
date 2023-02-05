import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import '../../../controllers/admin/admin_controllers.dart';
import '../../../controllers/routes.dart';
import '../../../controllers/utils.dart';

class CollectedUser extends StatelessWidget {
  final Map<String, dynamic>? data;
  const CollectedUser({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: data?["users"].length,
        itemBuilder: (context, index) {
          return data?["users"][index].isEmpty
              ? const SizedBox.shrink()
              : ListTile(
                  onTap: () async {
                    if (!checkEmpty(data?["users"][index])) {
                      Utils.loading();
                      var userData = await AdminControllers.fetchProfileData(
                          data?["users"][index]);
                      EasyLoading.dismiss();
                      Future.delayed(Duration.zero).then((value) {
                        context.push(AppRoutes.userDetails, extra: userData);
                      });
                    }
                  },
                  leading: Text(index.toString()),
                  trailing: IconButton(
                      onPressed: () {
                        openUrl("tel:${data?["users"][index]}");
                      },
                      icon: const CircleAvatar(child: Icon(Icons.call))),
                  title: Text(data?["users"][index]),
                );
        });
  }
}
