import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_app_flutter/config/app_colors.dart';
import 'package:laundry_app_flutter/config/failure.dart';
import 'package:laundry_app_flutter/config/nav.dart';
import 'package:laundry_app_flutter/datasources/shop_datasource.dart';
import 'package:laundry_app_flutter/models/shop_model.dart';
import 'package:laundry_app_flutter/pages/dashboard/detail_shop_page.dart';
import 'package:laundry_app_flutter/providers/search_by_city_provider.dart';

class SearchByCityPage extends ConsumerStatefulWidget {
  const SearchByCityPage({super.key, required this.query});
  final String query;

  @override
  ConsumerState<SearchByCityPage> createState() => _SearchByCityPageState();
}

class _SearchByCityPageState extends ConsumerState<SearchByCityPage> {
  final editSearch = TextEditingController();

  execute() {
    ShopDataSource.searchBycity(editSearch.text).then((value) {
      setSearchByCityStatus(ref, 'Loading');
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case BadRequestFailure:
              setSearchByCityStatus(ref, 'Bad request');
              break;
            case UnauthorizedFailure:
              setSearchByCityStatus(ref, "Unauthorized");
              break;
            case ForbiddenFailure:
              setSearchByCityStatus(ref, "You don't have permission");
              break;
            case NotFoundFailure:
              setSearchByCityStatus(ref, "Error not found");
              break;
            case InvalidInputFailure:
              setSearchByCityStatus(ref, "Invalid input");
              break;
            case ServerFailure:
              setSearchByCityStatus(ref, "Server error");
              break;
            default:
              setSearchByCityStatus(ref, "Request error");
              break;
          }
        },
        (result) {
          setSearchByCityStatus(ref, "Success");
          List data = result['data'];
          List<ShopModel> list =
              data.map((e) => ShopModel.fromJson(e)).toList();
          ref.read(searchByCityListProvider.notifier).setData(list);
        },
      );
    });
  }

  @override
  void initState() {
    if (widget.query != '') {
      editSearch.text = widget.query;

      execute();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text(
                'City: ',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  height: 1,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: editSearch,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(height: 1),
                  onSubmitted: (value) => execute(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => execute(),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Consumer(
        builder: (_, wiRef, __) {
          String status = wiRef.watch(searchByCityStatusProvider);
          List<ShopModel> list = wiRef.watch(searchByCityListProvider);

          if (status == '') {
            return DView.nothing();
          }

          if (status == 'Loading') {
            return DView.loadingCircle();
          }

          if (status == 'Success') {
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                ShopModel shop = list[index];

                return ListTile(
                  onTap: () {
                    Nav.push(context, DetailShopPage(shop: shop));
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    radius: 18,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(shop.name),
                  subtitle: Text(shop.city),
                  trailing: const Icon(Icons.navigate_next),
                );
              },
            );
          }

          return DView.error();
        },
      ),
    );
  }
}
