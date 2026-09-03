class AppConfig {
  /// Android emulator → host machine. Change for device/iOS as needed.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    //defaultValue: 'http://10.156.155.221:8000/api',
    //defaultValue: 'https://smart.lakgroup.org/api',
    defaultValue: 'http://10.0.2.2:8000/api', // Android emulator → host machine
  );

  static const String appName = 'Smart Money';
  static const double initialBalanceHint = 1000000;
}
