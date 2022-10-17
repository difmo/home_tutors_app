import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/profile_controllers.dart';

final cityListProvider =
    FutureProvider.autoDispose.family((Ref ref, String state) async {
  final apiService = ref.read(profileApiProviders);
  return apiService.getCityList(state);
});
