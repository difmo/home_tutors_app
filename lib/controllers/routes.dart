import 'package:app/views/auth/login_screen.dart';
import 'package:app/views/auth/registration_screen.dart';
import 'package:app/views/home/home_screen.dart';
import 'package:app/views/profile/teacher_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String teacherProfile = '/teacherProfile';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: <GoRoute>[
      GoRoute(
        path: login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrationScreen();
        },
      ),
      GoRoute(
        path: home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: teacherProfile,
        builder: (BuildContext context, GoRouterState state) {
          return TeacherProfileScreen();
        },
      ),
    ],
  );
}
