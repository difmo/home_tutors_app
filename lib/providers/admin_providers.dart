import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/admin/admin_controllers.dart';

final allPostsDataProvider = FutureProvider.autoDispose((Ref ref) async {
  final apiService = ref.read(adminApiProviders);
  return apiService.fetchAllPosts();
});

final allUsersDataProvider = FutureProvider.autoDispose((Ref ref) async {
  final apiService = ref.read(adminApiProviders);
  return apiService.fetchAllUsers();
});
