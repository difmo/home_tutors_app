import 'package:app/controllers/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column()),
      appBar: AppBar(title: const Text("Home"), centerTitle: false),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 100.0),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
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
