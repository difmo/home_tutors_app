import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/profile_controllers.dart';

final cityListProvider =
    FutureProvider.autoDispose.family((Ref ref, String state) async {
  final apiService = ref.read(profileApiProviders);
  return apiService.getCityList(state);
});

final profileDataProvider = FutureProvider.autoDispose((Ref ref) async {
  final apiService = ref.read(profileApiProviders);
  return apiService.fetchProfileData();
});

final alTransactionsProvider =
    FutureProvider.autoDispose.family((Ref ref, bool isAdmin) async {
  final apiService = ref.read(profileApiProviders);
  return apiService.fetchAllTransactions(isAdmin);
});

// final stateNameProvider = StateProvider<String>((ref) => "");
final selectedStateProvider = StateProvider<String>((ref) => "All");

final isRegisterProvider = StateProvider<bool>((ref) => false);
