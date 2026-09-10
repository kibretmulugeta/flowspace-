/// FlowSpace Environment and Runtime Configuration
///
/// Supports Development, Staging, and Production profiles.
/// Values can be injected at build time using:
///   --dart-define=API_BASE_URL=...
///   --dart-define-from-file=.env
library;

enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromString(String env) {
    switch (env.toLowerCase().trim()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableDebugLogs;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.enableDebugLogs = true,
  });

  bool get isProduction => environment == AppEnvironment.production;
  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isStaging => environment == AppEnvironment.staging;

  /// Loads configuration from compile-time environment variables or defaults
  factory AppConfig.fromEnvironment() {
    const envString = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    const baseApi = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/v1',
    );
    const supUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://placeholder.supabase.co',
    );
    const supAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'placeholder-anon-key',
    );

    final env = AppEnvironment.fromString(envString);

    return AppConfig(
      environment: env,
      apiBaseUrl: baseApi,
      supabaseUrl: supUrl,
      supabaseAnonKey: supAnonKey,
      enableDebugLogs: env != AppEnvironment.production,
    );
  }

  /// Global current configuration singleton instance
  static AppConfig current = AppConfig.fromEnvironment();

  /// Allows override during tests or app bootstrap
  static void set(AppConfig config) {
    current = config;
  }
}
