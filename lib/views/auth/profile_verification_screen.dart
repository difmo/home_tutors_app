import 'package:app/controllers/routes.dart';
import 'package:app/controllers/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';

class ProfileVerificationScreen extends StatelessWidget {
  final String? email;
  const ProfileVerificationScreen({super.key, this.email});

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
            if (checkEmpty(email)) ...[
              const Icon(
                Icons.error,
                size: 75.0,
                color: Colors.red,
              ),
              const SizedBox(height: 25.0),
              const Text("Your profile is incomplete",
                  style: pagetitleStyle, textAlign: TextAlign.center),
              const SizedBox(height: 25.0),
              const Text("Please complete your profile to get verified",
                  style: pageSubTitleStyle, textAlign: TextAlign.center),
            ] else ...[
              const Icon(
                Icons.access_time,
                size: 75.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 25.0),
              const Text("Your profile is under verification",
                  style: pagetitleStyle, textAlign: TextAlign.center),
              const SizedBox(height: 25.0),
              const Text(
                  "Our team will verify your account within 24 hours, then you can start exploring all opportunities",
                  style: pageSubTitleStyle,
                  textAlign: TextAlign.center),
            ],
            const SizedBox(height: 50.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.teacherProfile);
                      },
                      child: Text(checkEmpty(email)
                          ? "Complete profile"
                          : "Edit profile")),
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
