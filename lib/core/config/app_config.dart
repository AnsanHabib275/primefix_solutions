class AppConfig {
  static const String appName = 'ServiceHub';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.servicehub.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Firebase Configuration
  static const String firebaseProjectId = 'servicehub-app';

  // Payment Configuration
  static const String stripePublishableKey = 'pk_test_...';

  // Map Configuration
  static const String googleMapsApiKey = 'AIza...';

  // Features
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
}
