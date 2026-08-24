class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS simulator / Web / Desktop
  // Or replace with your local machine's IP (e.g. 192.168.1.x:8000) when testing on physical devices
  static String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String logoutEndpoint = '/auth/logout';
  static const String settingsEndpoint = '/settings';
  static const String bannersEndpoint = '/banners';
  static const String categoriesEndpoint = '/categories';
  static const String productsEndpoint = '/products';
}
