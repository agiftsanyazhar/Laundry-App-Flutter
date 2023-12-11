import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:laundry_app_flutter/config/app_assets.dart';
import 'package:laundry_app_flutter/config/app_colors.dart';
import 'package:laundry_app_flutter/config/app_constants.dart';
import 'package:laundry_app_flutter/config/app_format.dart';
import 'package:laundry_app_flutter/models/shop_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class DetailShopPage extends StatelessWidget {
  const DetailShopPage({super.key, required this.shop});
  final ShopModel shop;

  launchWa(BuildContext context, String number) async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Chat Via WhatsApp',
      'Yes to Confirm',
    );

    if (yes ?? false) {
      final link = WhatsAppUnilink(
        phoneNumber: number,
        text: 'Hello, Laundry App',
      );

      if (await canLaunchUrl(link.asUri())) {
        launchUrl(
          link.asUri(),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          headerImage(context),
          DView.height(10),
          groupItemInfo(context),
          DView.height(20),
          category(),
          DView.height(20),
          description(),
          DView.height(20),
          orderButton(),
          DView.height(20),
        ],
      ),
    );
  }

  Widget headerImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                '${AppConstants.baseImageUrl}/${shop.image}',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AspectRatio(
                aspectRatio: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DView.height(8),
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: shop.rate,
                            itemCount: 5,
                            allowHalfRating: true,
                            itemPadding: const EdgeInsets.all(0),
                            unratedColor: Colors.grey[300],
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemSize: 12,
                            onRatingUpdate: (value) {},
                            ignoreGestures: true,
                          ),
                          DView.width(4),
                          Text(
                            '(${shop.rate})',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      !shop.delivery && !shop.pickup
                          ? DView.nothing()
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  if (shop.delivery) childOrder('Delivery'),
                                  if (shop.pickup) DView.width(8),
                                  childOrder('Pickup'),
                                ],
                              ),
                            ),
                    ],
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
    );
  }

  Container childOrder(String name) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.green,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              height: 1,
            ),
          ),
          DView.width(4),
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget itemInfo(Widget icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 20,
          alignment: Alignment.centerLeft,
          child: icon,
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Padding groupItemInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                itemInfo(
                  const Icon(
                    Icons.location_city_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  shop.city,
                ),
                DView.height(6),
                itemInfo(
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  shop.location,
                ),
                DView.height(6),
                GestureDetector(
                  onTap: () => launchWa(context, shop.whatsapp),
                  child: itemInfo(
                    Image.asset(
                      AppAssets.wa,
                      width: 20,
                    ),
                    shop.whatsapp,
                  ),
                ),
              ],
            ),
          ),
          DView.width(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormat.longPrice(shop.price),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  height: 1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text('/ kg'),
            ],
          ),
        ],
      ),
    );
  }

  Padding category() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DView.textTitle('Category', color: Colors.black87),
          DView.height(8),
          Wrap(
            spacing: 8,
            children: [
              'Economical',
              'Exclusive',
              'Express',
              'Regular',
            ].map((e) {
              return Chip(
                visualDensity: const VisualDensity(vertical: -4),
                label: Text(e, style: const TextStyle(height: 1)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.primary),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Padding description() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DView.textTitle('Category', color: Colors.black87),
          DView.height(8),
          Text(
            shop.description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Container orderButton() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {},
        child: const Text(
          'Order',
          style: TextStyle(height: 1, fontSize: 18),
        ),
      ),
    );
  }
}
