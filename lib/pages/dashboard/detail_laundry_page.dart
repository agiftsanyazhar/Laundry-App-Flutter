import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:laundry_app_flutter/config/app_assets.dart';
import 'package:laundry_app_flutter/config/app_colors.dart';
import 'package:laundry_app_flutter/config/app_format.dart';
import 'package:laundry_app_flutter/config/nav.dart';
import 'package:laundry_app_flutter/models/laundry_model.dart';
import 'package:laundry_app_flutter/pages/dashboard/detail_shop_page.dart';

class DetailLaundryPage extends StatelessWidget {
  const DetailLaundryPage({super.key, required this.laundry});
  final LaundryModel laundry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          headerCover(context),
          DView.height(10),
          separator(),
          DView.height(),
          itemInfo(Icons.sell, AppFormat.longPrice(laundry.total)),
          divider(),
          itemInfo(Icons.event, AppFormat.fullDate(laundry.createdAt)),
          divider(),
          InkWell(
            onTap: () {
              Nav.push(context, DetailShopPage(shop: laundry.shop));
            },
            child: itemInfo(Icons.store, laundry.shop.name),
          ),
          divider(),
          itemInfo(Icons.shopping_basket, '${laundry.weight} kg'),
          divider(),
          if (laundry.withDelivery) itemInfo(Icons.shopping_bag, 'Delivery'),
          if (laundry.withDelivery) itemDescription(laundry.deliveryAddress),
          if (laundry.withDelivery) divider(),
          if (laundry.withPickup) itemInfo(Icons.local_shipping, 'Pickup'),
          if (laundry.withPickup) itemDescription(laundry.pickupAddress),
          if (laundry.withPickup) divider(),
          itemInfo(Icons.description, 'Description'),
          itemDescription(laundry.description),
          divider(),
        ],
      ),
    );
  }

  Padding headerCover(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppAssets.emptyBg,
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  child: Text(
                    laundry.status,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 36,
                left: 16,
                child: SizedBox(
                  height: 36,
                  child: FloatingActionButton.extended(
                    heroTag: 'fab-back-button',
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    icon: const Icon(Icons.navigate_before),
                    extendedIconLabelSpacing: 0,
                    extendedPadding: const EdgeInsets.only(
                      left: 10,
                      right: 16,
                    ),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        height: 1,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center separator() {
    return Center(
      child: Container(
        width: 90,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget itemInfo(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          DView.width(10),
          Text(info),
        ],
      ),
    );
  }

  Widget itemDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          const Icon(Icons.abc, color: Colors.transparent),
          DView.width(10),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Divider divider() {
    return Divider(
      indent: 30,
      endIndent: 30,
      color: Colors.grey[400],
    );
  }
}
