enum ThemePreference { system, light, dark }

abstract interface class SettingsRepository {
  Future<ThemePreference> loadTheme();

  Future<void> saveTheme(ThemePreference theme);
}
