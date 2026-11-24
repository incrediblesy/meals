import 'package:shared_preferences/shared_preferences.dart';

import 'package:meals/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferencesAsync preferences;

  static const _themeKey = 'meals.settings.theme';

  SettingsRepositoryImpl(this.preferences);

  @override
  Future<ThemePreference> loadTheme() async {
    final value = await preferences.getString(_themeKey);

    return switch (value) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      _ => ThemePreference.system,
    };
  }

  @override
  Future<void> saveTheme(ThemePreference theme) {
    return preferences.setString(_themeKey, theme.name);
  }
}
