import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app_flutter/models/shop_model.dart';

final setSearchByCityStatusProvider = StateProvider.autoDispose((ref) => '');

final searchByCityStatusProvider = StateProvider.autoDispose((ref) => '');

setSearchByCityStatus(WidgetRef ref, String newStatus) {
  ref.read(searchByCityStatusProvider.notifier).state = newStatus;
}

final searchByCityListProvider =
    StateNotifierProvider.autoDispose<SearchByCityList, List<ShopModel>>(
  (ref) => SearchByCityList([]),
);

class SearchByCityList extends StateNotifier<List<ShopModel>> {
  SearchByCityList(super.state);

  setData(newList) {
    state = newList;
  }
}
