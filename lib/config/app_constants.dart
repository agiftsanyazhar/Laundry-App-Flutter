class AppConstants {
  static const appName = "Laundry App";

  static const _host = "http://192.168.0.129/laundry-app/public";

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
}
