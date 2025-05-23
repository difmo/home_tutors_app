import 'package:app/controllers/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/profile_provider.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/onboaring.jpeg"))),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              context.go(AppRoutes.login);
                            },
                            child: const Text('Login'))),
                    const SizedBox(width: 25.0),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            ref.read(isRegisterProvider.notifier).state = true;
                            context.go(AppRoutes.login);
                          },
                          child: const Text('Register')),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
