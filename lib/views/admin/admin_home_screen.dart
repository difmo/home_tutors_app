import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/routes.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: const [],
      )),
      appBar: AppBar(
        title: const Text('Leads'),
        centerTitle: false,
        actions: [
          TextButton.icon(
              onPressed: () {
                context.push(AppRoutes.addNewLead);
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: const Text(
                'New lead',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 30.0,
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white)),
                    Icon(
                      Icons.verified,
                      color: Colors.blue.shade900,
                    )
                  ],
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ??
                          "admin@site.com",
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            )),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle_sharp),
              title: const Text('Users'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.balance),
              title: const Text('Transaction'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                context.go(AppRoutes.login);
              },
            )
          ],
        ),
      ),
    );
  }
}
