
import 'package:app/controllers/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/routes.dart';
import '../constants.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;

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
            const Text("Verify your email", style: pagetitleStyle),
            const SizedBox(height: 25.0),
            Text(
              currentUser!.email!,
              style: pageSubTitleStyle,
            ),
            const SizedBox(height: 25.0),
            const Text(
                "To visit your email address, please tap on the link sent to your email address, also don't forget to check your spam folder",
                textAlign: TextAlign.center),
            const SizedBox(height: 50.0),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          Utils.loading();
                          await FirebaseAuth.instance.currentUser!.reload();
                          EasyLoading.dismiss();
                          if (FirebaseAuth
                              .instance.currentUser!.emailVerified) {
                            if (mounted) {
                              context.go(AppRoutes.teacherProfile);
                            }
                          }
                        },
                        child: const Text("Check status"))),
                const SizedBox(width: 25.0),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        Utils.loading();
                        currentUser!.sendEmailVerification();
                        EasyLoading.dismiss();
                      },
                      child: const Text("Resend email")),
                ),
              ],
            ),
            const SizedBox(height: 25.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      context.go(AppRoutes.login);
                    },
                    child: const Text("Logout")),
                const SizedBox(width: 25.0),
                TextButton(
                    onPressed: () {}, child: const Text("Contact support")),
              ],
            )
          ],
        ),
      )),
    );
  }
}
