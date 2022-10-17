import 'package:app/controllers/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView.separated(
              itemCount: 30,
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text("${index + 1}."),
                  title: const Text('History home tutor needed'),
                  subtitle: const Text(
                      'Chapman 711-2880 Nulla St. Mankato Mississippi 96522'),
                  trailing: const Icon(Icons.navigate_next_outlined),
                );
              })),
      appBar: AppBar(title: const Text("Home"), centerTitle: false),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 30.0,
                    backgroundImage:
                        AssetImage('assets/placeholder_user.jpeg')),
                const SizedBox(height: 10.0),
                Text(
                  'User Name',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  'Chapman 711-2880 Nulla St. Mankato Mississippi 96522',
                ),
              ],
            )),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                FirebaseAuth.instance.signOut();
                context.push(AppRoutes.teacherProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Contact support"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text("Terms & Conditions"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                FirebaseAuth.instance.signOut();
                context.go(AppRoutes.login);
              },
            ),
            const SizedBox(height: 10.0),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'App version: v0.0.1',
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
