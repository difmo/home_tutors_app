import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/admin/admin_controllers.dart';

final searchUserFutureProvider =
    FutureProvider.autoDispose.family((Ref ref, String searchValue) async {
  final apiService = ref.read(adminApiProviders);
  return apiService.searchUser(searchValue);
});

final connectedAppsFutureProvider = FutureProvider.autoDispose((Ref ref) async {
  final apiService = ref.read(adminApiProviders);
  return apiService.getConnectedApps();
});

final feedbacksFutureProvider = FutureProvider.autoDispose((Ref ref) async {
  final apiService = ref.read(adminApiProviders);
  return apiService.getFeedbacks();
});

// final matchedUsersFutureProvider = FutureProvider.autoDispose
//     .family((Ref ref, GetMatchedUsersApiModel data) async {
//   final apiService = ref.read(adminApiProviders);
//   return apiService.getMatchedUsers(data);
// });
