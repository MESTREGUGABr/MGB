class AppConfig {
  static const rawgApiKey = String.fromEnvironment('RAWG_API_KEY', defaultValue: '');

  static bool get hasRawgKey => rawgApiKey.isNotEmpty;
}
