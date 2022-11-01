import 'package:app/controllers/auth_controllers.dart';
import 'package:app/views/admin/add_post_screen.dart';
import 'package:app/views/admin/admin_home_screen.dart';
import 'package:app/views/admin/all_transactions_screen.dart';
import 'package:app/views/admin/user_details_screen.dart';
import 'package:app/views/admin/users_list.dart';
import 'package:app/views/auth/email_verification_screen.dart';
import 'package:app/views/auth/login_screen.dart';
import 'package:app/views/auth/registration_screen.dart';
import 'package:app/views/user/home/home_screen.dart';
import 'package:app/views/onboarding_screen.dart';
import 'package:app/views/posts/post_details.dart';
import 'package:app/views/user/profile/teacher_profile_screen.dart';
import 'package:app/views/user/wallet/wallet_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email_verification';
  static const String userDetails = '/user_details';

  static const String home = '/home';
  static const String teacherProfile = '/teacher_profile';
  static const String adminHome = '/admin_home';
  static const String addNewLead = '/add_new_lead';
  static const String allUsersList = '/all_users_list';
  static const String walletScreen = '/wallet_screen';
  static const String allTransactions = '/all_transactions';
  static const String postDetails = '/post_details';

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
        path: emailVerification,
        builder: (BuildContext context, GoRouterState state) {
          return const EmailVerificationScreen();
        },
      ),
      GoRoute(
        path: userDetails,
        builder: (BuildContext context, GoRouterState state) {
          return UserDetailsScreen(
            item: state.extra as QueryDocumentSnapshot<Map<String, dynamic>>?,
          );
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
      GoRoute(
        path: allTransactions,
        builder: (BuildContext context, GoRouterState state) {
          return const AllTransactionsScreen();
        },
      ),
      GoRoute(
        path: postDetails,
        builder: (BuildContext context, GoRouterState state) {
          return PostDetailsScreen(
            postData:
                state.extra as QueryDocumentSnapshot<Map<String, dynamic>>?,
          );
        },
      ),
    ],
  );
}
