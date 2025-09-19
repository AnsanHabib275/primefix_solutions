class Environment {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  static bool get isDev => _environment == 'dev';
  static bool get isStaging => _environment == 'staging';
  static bool get isProd => _environment == 'prod';

  static String get baseUrl {
    switch (_environment) {
      case 'prod':
        return 'https://api.servicehub.com';
      case 'staging':
        return 'https://staging-api.servicehub.com';
      default:
        return 'https://dev-api.servicehub.com';
    }
  }

  static String get firebaseProjectId {
    switch (_environment) {
      case 'prod':
        return 'servicehub-prod';
      case 'staging':
        return 'servicehub-staging';
      default:
        return 'servicehub-dev';
    }
  }
}
