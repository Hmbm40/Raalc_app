enum AppEnv { dev, staging, prod }

class Env {
  static const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api.example.com');
  static const enableLogs = bool.fromEnvironment('ENABLE_LOGS', defaultValue: true);

  static AppEnv get current => switch (appEnv) {
        'prod' => AppEnv.prod,
        'staging' => AppEnv.staging,
        _ => AppEnv.dev,
      };
}
