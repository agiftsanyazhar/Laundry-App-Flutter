import 'package:flutter/material.dart';
import 'package:laundry_app_flutter/pages/dashboard/dashboard_views/account_view.dart';
import 'package:laundry_app_flutter/pages/dashboard/dashboard_views/home_view.dart';
import 'package:laundry_app_flutter/pages/dashboard/dashboard_views/my_laundry_view.dart';

class AppConstants {
  static const appName = "Laundry App";

  // static const _host = "http://192.168.18.7/laundry-app/public";
  static const _host = "https://laundry-app.agiftsany-azhar.web.id";

  static const baseUrl = "$_host/api";

  static const baseImageUrl = "$_host/storage";

  static const laundryStatusCategory = [
    'All',
    'Pickup',
    'Queue',
    'Process',
    'Washing',
    'Dried',
    'Ironed',
    'Done',
    'Delivery',
  ];

  static List<Map> navMenuDashboard = [
    {
      'view': const HomeView(),
      'icon': Icons.home_filled,
      'label': 'Home',
    },
    {
      'view': const MyLaundryview(),
      'icon': Icons.local_laundry_service,
      'label': 'My Laundry',
    },
    {
      'view': const AccountView(),
      'icon': Icons.account_circle,
      'label': 'Account',
    }
  ];

  static const homeCategories = [
    'All',
    'Economical',
    'Exclusive',
    'Express',
    'Regular',
  ];
}
