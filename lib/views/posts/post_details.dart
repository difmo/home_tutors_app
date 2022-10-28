import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? postData;
  const PostDetailsScreen({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(postData?["title"], style: pagetitleStyle),
              const SizedBox(height: 15.0),
              Text(postData?["desc"]),
              const SizedBox(height: 15.0),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      formatWithMonthNameTime
                          .format(postData?["createdOn"].toDate()),
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12.0))),
              _DetailsTile(
                  icon: Icons.location_on,
                  title: postData?["city"] + " - " + postData?["state"],
                  subTitle: postData?["locality"]),
              _DetailsTile(
                  icon: Icons.wallet,
                  title: "Coins needed: ${postData?["req_coins"]}"),
              _DetailsTile(icon: Icons.book, title: postData?["subject"]),
              _DetailsTile(
                  icon: Icons.edit_note_sharp,
                  title: "Class: ${postData?["class"]}"),
              _DetailsTile(
                  icon: Icons.monetization_on,
                  title: "Fee: ₹${postData?["fee"]} per hour"),
              _DetailsTile(
                  icon: Icons.female, title: "Gender: ${postData?["gender"]}"),
              _DetailsTile(
                  icon: Icons.switch_video_outlined,
                  title: "Mode: ${postData?["mode"]}"),
              _DetailsTile(
                  icon: Icons.work,
                  title: "Prefered Experience: ${postData?["req_exp"]} years"),
              _DetailsTile(
                  icon: Icons.school,
                  title: "Prefered Qualification: ${postData?["qualify"]}"),
            ],
          ),
        ),
      )),
      appBar: AppBar(
        title: Text(postData?["title"]),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text(
                "0/${postData?["max_hits"]}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AuthControllers.isAdmin()
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.green,
              child: const Text("Grab"),
              onPressed: () {}),
    );
  }
}

class _DetailsTile extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? subTitle;

  const _DetailsTile({required this.icon, required this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title ?? ""),
      subtitle: subTitle == null ? null : Text(subTitle ?? ""),
    );
  }
}
