enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  // Current environment - change this to switch environments
  static const Environment currentEnvironment = Environment.development;

  // Development configuration
  static const Map<String, String> development = {
    'apiBaseUrl': 'http://localhost:8000',
    'webSocketUrl': 'ws://localhost:8000',
    'name': 'Development',
  };

  // Staging configuration
  static const Map<String, String> staging = {
    'apiBaseUrl': 'https://staging-api.cupido.com',
    'webSocketUrl': 'wss://staging-api.cupido.com',
    'name': 'Staging',
  };

  // Production configuration
  static const Map<String, String> production = {
    'apiBaseUrl': 'https://api.cupido.com',
    'webSocketUrl': 'wss://api.cupido.com',
    'name': 'Production',
  };

  // Get current configuration
  static Map<String, String> get current {
    switch (currentEnvironment) {
      case Environment.development:
        return development;
      case Environment.staging:
        return staging;
      case Environment.production:
        return production;
    }
  }

  // Get API base URL for current environment
  static String get apiBaseUrl => current['apiBaseUrl']!;

  // Get WebSocket URL for current environment
  static String get webSocketUrl => current['webSocketUrl']!;

  // Get environment name
  static String get environmentName => current['name']!;

  // Check if in development
  static bool get isDevelopment => currentEnvironment == Environment.development;

  // Check if in staging
  static bool get isStaging => currentEnvironment == Environment.staging;

  // Check if in production
  static bool get isProduction => currentEnvironment == Environment.production;
}
