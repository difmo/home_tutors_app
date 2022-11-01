import 'package:app/controllers/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class ProfileVerificationScreen extends StatelessWidget {
  const ProfileVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Your profile is under verification",
                style: pagetitleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 50.0),
            const Text(
                "Our team will verify your account within 24 hours, then you can start exploring all opportunities",
                style: pageSubTitleStyle,
                textAlign: TextAlign.center),
            const SizedBox(height: 25.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.teacherProfile);
                      },
                      child: const Text("Edit profile")),
                ),
                const SizedBox(width: 25.0),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        context.go(AppRoutes.login);
                      },
                      child: const Text("Logout")),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
