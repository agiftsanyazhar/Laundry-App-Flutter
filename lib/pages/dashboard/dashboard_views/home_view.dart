import 'package:d_button/d_button.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundry_app_flutter/config/app_assets.dart';
import 'package:laundry_app_flutter/config/app_colors.dart';
import 'package:laundry_app_flutter/config/app_constants.dart';
import 'package:laundry_app_flutter/config/app_format.dart';
import 'package:laundry_app_flutter/config/failure.dart';
import 'package:laundry_app_flutter/config/nav.dart';
import 'package:laundry_app_flutter/datasources/promo_datasource.dart';
import 'package:laundry_app_flutter/datasources/shop_datasource.dart';
import 'package:laundry_app_flutter/models/promo_model.dart';
import 'package:laundry_app_flutter/models/shop_model.dart';
import 'package:laundry_app_flutter/pages/dashboard/detail_shop_page.dart';
import 'package:laundry_app_flutter/pages/dashboard/search_by_city_page.dart';
import 'package:laundry_app_flutter/providers/home_provider.dart';
import 'package:laundry_app_flutter/widgets/error_background.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  static final editSearch = TextEditingController();

  goToSearchCity() {
    Nav.push(context, SearchByCityPage(query: editSearch.text));
  }

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

  refreshIndicator() {
    getPromo();
    getRecommendationLimit();
  }

  @override
  void initState() {
    refreshIndicator();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => refreshIndicator(),
      child: ListView(
        children: [
          header(),
          categories(),
          DView.height(20),
          promo(),
          DView.height(20),
          recommendation(),
          DView.height(20),
        ],
      ),
    );
  }

  Padding header() {
    return Padding(
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
    );
  }

  Consumer categories() {
    return Consumer(
      builder: (_, wiRef, __) {
        String categorySelected = wiRef.watch(homeCategoryProvider);

        return SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.homeCategories.length,
            itemBuilder: (context, index) {
              String category = AppConstants.homeCategories[index];

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  index == 0 ? 30 : 8,
                  0,
                  index == AppConstants.homeCategories.length - 1 ? 30 : 8,
                  0,
                ),
                child: InkWell(
                  onTap: () {
                    setHomeCategory(ref, category);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: categorySelected == category
                            ? Colors.green
                            : Colors.grey[400]!,
                      ),
                      color: categorySelected == category
                          ? Colors.green
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      category,
                      style: TextStyle(
                        height: 1,
                        color: categorySelected == category
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Consumer promo() {
    final pageController = PageController();

    return Consumer(
      builder: (_, wiRef, __) {
        List<PromoModel> list = wiRef.watch(homePromoListProvider);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DView.textTitle('Promo', color: Colors.black),
                  DView.textAction(() {}, color: AppColors.primary),
                ],
              ),
            ),
            list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: ErrorBackground(
                      ratio: 16 / 9,
                      message: 'No Promo',
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        PromoModel item = list[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage(
                                    placeholder: const AssetImage(
                                        AppAssets.placeholderLaundry),
                                    image: NetworkImage(
                                        '${AppConstants.baseImageUrl}/${item.image}'),
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.shop.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      DView.height(4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${AppFormat.shortPrice(item.newPrice)} / kg',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          DView.width(),
                                          Text(
                                            '${AppFormat.shortPrice(item.oldPrice)} / kg',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            if (list.isNotEmpty) DView.height(8),
            if (list.isNotEmpty)
              SmoothPageIndicator(
                controller: pageController,
                count: list.length,
                effect: WormEffect(
                  dotHeight: 4,
                  dotWidth: 12,
                  dotColor: Colors.grey[300]!,
                  activeDotColor: AppColors.primary,
                ),
              ),
          ],
        );
      },
    );
  }

  Consumer recommendation() {
    return Consumer(
      builder: (_, wiRef, __) {
        List<ShopModel> list = wiRef.watch(homeRecommendationListProvider);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DView.textTitle('Recommendation', color: Colors.black),
                  DView.textAction(() {}, color: AppColors.primary),
                ],
              ),
            ),
            list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: ErrorBackground(
                      ratio: 1.2,
                      message: 'No Recommendation',
                    ),
                  )
                : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        ShopModel item = list[index];

                        return GestureDetector(
                          onTap: () {
                            Nav.push(context, DetailShopPage(shop: item));
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                              index == 0 ? 30 : 10,
                              0,
                              index == list.length - 1 ? 30 : 10,
                              0,
                            ),
                            width: 200,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage(
                                    placeholder: const AssetImage(
                                        AppAssets.placeholderLaundry),
                                    image: NetworkImage(
                                        '${AppConstants.baseImageUrl}/${item.image}'),
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 150,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  right: 8,
                                  child: Column(
                                    children: [
                                      Row(
                                        children:
                                            ['Express', 'Regular'].map((e) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            margin:
                                                const EdgeInsets.only(right: 4),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                height: 1,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      DView.height(8),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: GoogleFonts.ptSans(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            DView.height(4),
                                            Row(
                                              children: [
                                                RatingBar.builder(
                                                  initialRating: item.rate,
                                                  itemCount: 5,
                                                  allowHalfRating: true,
                                                  itemPadding:
                                                      const EdgeInsets.all(0),
                                                  unratedColor:
                                                      Colors.grey[300],
                                                  itemBuilder:
                                                      (context, index) =>
                                                          const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  itemSize: 12,
                                                  onRatingUpdate: (value) {},
                                                  ignoreGestures: true,
                                                ),
                                                DView.width(4),
                                                Text(
                                                  '(${item.rate})',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            DView.height(4),
                                            Text(
                                              item.location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        );
      },
    );
  }
}
