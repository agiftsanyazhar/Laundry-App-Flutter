import 'package:d_button/d_button.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app_flutter/config/failure.dart';
import 'package:laundry_app_flutter/datasources/promo_datasource.dart';
import 'package:laundry_app_flutter/datasources/shop_datasource.dart';
import 'package:laundry_app_flutter/models/promo_model.dart';
import 'package:laundry_app_flutter/models/shop_model.dart';
import 'package:laundry_app_flutter/providers/home_provider.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  static final editSearch = TextEditingController();

  goToSearchCity() {}

  getPromo() {
    PromoDataSource.readLimit().then((value) {
      value.fold((failure) {
        switch (failure.runtimeType) {
          case BadRequestFailure:
            setHomePromoStatus(ref, 'Bad request');
            break;
          case UnauthorizedFailure:
            setHomePromoStatus(ref, "Unauthorized");
            break;
          case ForbiddenFailure:
            setHomePromoStatus(ref, "You don't have permission");
            break;
          case NotFoundFailure:
            setHomePromoStatus(ref, "Error not found");
            break;
          case InvalidInputFailure:
            setHomePromoStatus(ref, "Invalid input");
            break;
          case ServerFailure:
            setHomePromoStatus(ref, "Server error");
            break;
          default:
            setHomePromoStatus(ref, "Request error");
            break;
        }
      }, (result) {
        setHomePromoStatus(ref, "Success");
        List data = result['data'];
        List<PromoModel> promos =
            data.map((e) => PromoModel.fromJson(e)).toList();
        ref.read(homePromoListProvider.notifier).setData(promos);
      });
    });
  }

  getRecommendationLimit() {
    ShopDataSource.readRecommendationLimit().then((value) {
      value.fold((failure) {
        switch (failure.runtimeType) {
          case BadRequestFailure:
            setHomeRecomendationStatus(ref, 'Bad request');
            break;
          case UnauthorizedFailure:
            setHomeRecomendationStatus(ref, "Unauthorized");
            break;
          case ForbiddenFailure:
            setHomeRecomendationStatus(ref, "You don't have permission");
            break;
          case NotFoundFailure:
            setHomeRecomendationStatus(ref, "Error not found");
            break;
          case InvalidInputFailure:
            setHomeRecomendationStatus(ref, "Invalid input");
            break;
          case ServerFailure:
            setHomeRecomendationStatus(ref, "Server error");
            break;
          default:
            setHomeRecomendationStatus(ref, "Request error");
            break;
        }
      }, (result) {
        setHomeRecomendationStatus(ref, "Success");
        List data = result['data'];
        List<ShopModel> shops = data.map((e) => ShopModel.fromJson(e)).toList();
        ref.read(homeRecommendationListProvider.notifier).setData(shops);
      });
    });
  }

  @override
  void initState() {
    getPromo();
    getRecommendationLimit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We are ready",
                style: GoogleFonts.ptSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DView.height(4),
              Text(
                "to clean your clothes",
                style: GoogleFonts.ptSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1,
                ),
              ),
              DView.height(20),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        color: Colors.green,
                        size: 20,
                      ),
                      DView.height(20),
                      Text(
                        'Find by city',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  DView.height(8),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => goToSearchCity(),
                                  icon: const Icon(Icons.search),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: editSearch,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search',
                                    ),
                                    onSubmitted: (value) => goToSearchCity(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DView.width(),
                        DButtonElevation(
                          onClick: () {},
                          mainColor: Colors.green,
                          splashColor: Colors.greenAccent,
                          width: 50,
                          radius: 10,
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
