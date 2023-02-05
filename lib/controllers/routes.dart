import 'package:app/controllers/auth_controllers.dart';
import 'package:app/controllers/utils.dart';
import 'package:app/views/admin/add_post_screen.dart';
import 'package:app/views/admin/admin_home_screen.dart';
import 'package:app/views/admin/all_transactions_screen.dart';
import 'package:app/views/admin/amount_options_screen.dart';
import 'package:app/views/admin/search_result_screen.dart';
import 'package:app/views/admin/user_details_screen.dart';
import 'package:app/views/admin/user_feedbacks_screen.dart';
import 'package:app/views/admin/users_list.dart';
import 'package:app/views/admin/wallet_hits_screen.dart';
import 'package:app/views/auth/login_screen.dart';
import 'package:app/views/auth/otp_screen.dart';
import 'package:app/views/notifications_screen.dart';
import 'package:app/views/shared/connected_apps.dart';
import 'package:app/views/user/about_us_screen.dart';
import 'package:app/views/user/feedback_screen.dart';
import 'package:app/views/user/home/home_screen.dart';
import 'package:app/views/onboarding_screen.dart';
import 'package:app/views/shared/posts/post_details.dart';
import 'package:app/views/user/profile/teacher_profile_screen.dart';
import 'package:app/views/user/rules_screen.dart';
import 'package:app/views/user/wallet/wallet_history_screen.dart';
import 'package:app/views/user/wallet/wallet_screen.dart';
import 'package:app/views/widgets/image_full_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String dynamicUriPrifix = "https://viptutors.page.link";

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String otpScreen = '/otp_screen';

  static const String userDetails = '/user_details';

  static const String home = '/home';
  static const String teacherProfile = '/teacher_profile';
  static const String adminHome = '/admin_home';
  static const String addNewLead = '/add_new_lead';
  static const String allUsersList = '/all_users_list';
  static const String walletScreen = '/wallet_screen';
  static const String walletHistory = '/wallet_history';
  static const String allTransactions = '/all_transactions';
  static const String amountOptionsScreen = '/amount_options';
  static const String searchResults = '/search_results';

  static const String walletHits = '/wallet_hits';
  static const String postDetails = '/post_details:id';
  static const String imageView = '/image_view';
  static const String rulesScreen = '/rules_screen';
  static const String notifications = '/notifications';
  static const String connectedApps = '/connected_apps';
  static const String feedbackScreen = '/feedback_screen';
  static const String userFeedbacksScreen = '/user_feedbacks_screen';
  static const String aboutUsScreen = '/about_us';

  static final GoRouter router = GoRouter(
    initialLocation: AuthControllers.manageLogin(),
    navigatorKey: GlobalVariable.navState,
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
        path: otpScreen,
        builder: (BuildContext context, GoRouterState state) {
          return OtpVerifyScreen(
            data: state.extra as SendOtpResponseModel,
          );
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
          return TeacherProfileScreen(
            uid: state.extra as String?,
          );
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
          return AddLeadScreen(
            editData: state.extra as EditPostModel?,
          );
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
        path: walletHits,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletHitsScreen();
        },
      ),
      GoRoute(
        path: amountOptionsScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const AmountOptionsScreen();
        },
      ),
      GoRoute(
        path: postDetails,
        name: postDetails,
        builder: (BuildContext context, GoRouterState state) {
          return PostDetailsScreen(
              id: state.params["id"] ?? "",
              data: state.extra as Map<String, dynamic>?);
        },
      ),
      GoRoute(
        path: searchResults,
        builder: (BuildContext context, GoRouterState state) {
          return SearchResuleScreen(
            searchKey: state.extra as String,
          );
        },
      ),
      GoRoute(
        path: imageView,
        builder: (BuildContext context, GoRouterState state) {
          return ImageFullView(
            imageurl: state.extra as String,
          );
        },
      ),
      GoRoute(
        path: walletHistory,
        builder: (BuildContext context, GoRouterState state) {
          return const WalletHistory();
        },
      ),
      GoRoute(
        path: rulesScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const RulesScreen();
        },
      ),
      GoRoute(
        path: notifications,
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsScreen();
        },
      ),
      GoRoute(
        path: connectedApps,
        builder: (BuildContext context, GoRouterState state) {
          return const ConnectedAppsScreen();
        },
      ),
      GoRoute(
        path: feedbackScreen,
        builder: (BuildContext context, GoRouterState state) {
          return FeedbackScreen();
        },
      ),
      GoRoute(
        path: userFeedbacksScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const UserFeedbackScreen();
        },
      ),
      GoRoute(
        path: aboutUsScreen,
        builder: (BuildContext context, GoRouterState state) {
          return const AboutUsScreen();
        },
      ),
    ],
  );
}
