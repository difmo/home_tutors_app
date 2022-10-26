import 'package:app/controllers/auth_controllers.dart';
import 'package:app/views/admin/add_post_screen.dart';
import 'package:app/views/admin/admin_home_screen.dart';
import 'package:app/views/admin/users_list.dart';
import 'package:app/views/auth/login_screen.dart';
import 'package:app/views/auth/registration_screen.dart';
import 'package:app/views/home/home_screen.dart';
import 'package:app/views/onboarding_screen.dart';
import 'package:app/views/profile/teacher_profile_screen.dart';
import 'package:app/views/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String teacherProfile = '/teacher_profile';
  static const String adminHome = '/admin_home';
  static const String addNewLead = '/add_new_lead';
  static const String allUsersList = '/all_users_list';
  static const String walletScreen = '/wallet_screen';

  static final GoRouter router = GoRouter(
    initialLocation: AuthControllers.manageLogin(),
    routes: <GoRoute>[
      GoRoute(
        path: onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
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
        path: walletScreen,
        builder: (BuildContext context, GoRouterState state) {
          return WalletScreen();
        },
      ),
      GoRoute(
        path: teacherProfile,
        builder: (BuildContext context, GoRouterState state) {
          return TeacherProfileScreen();
        },
      ),
      GoRoute(
        path: adminHome,
        builder: (BuildContext context, GoRouterState state) {
          return const AdminHomeScreen();
        },
      ),
      GoRoute(
        path: addNewLead,
        builder: (BuildContext context, GoRouterState state) {
          return AddLeadScreen();
        },
      ),
      GoRoute(
        path: allUsersList,
        builder: (BuildContext context, GoRouterState state) {
          return const UsersListScreen();
        },
      ),
    ],
  );
}
