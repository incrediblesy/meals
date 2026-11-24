import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/settings/domain/repositories/settings_repository.dart';
import 'package:meals/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:meals/features/settings/presentation/cubit/settings_state.dart';

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference storedTheme = ThemePreference.system;

  bool failOnSave = false;
  bool failOnLoad = false;

  @override
  Future<ThemePreference> loadTheme() async {
    if (failOnLoad) {
      throw Exception('Load failed');
    }

    return storedTheme;
  }

  @override
  Future<void> saveTheme(ThemePreference theme) async {
    if (failOnSave) {
      throw Exception('Save failed');
    }

    storedTheme = theme;
  }
}

void main() {
  late FakeSettingsRepository repository;
  late SettingsCubit cubit;

  setUp(() {
    repository = FakeSettingsRepository();

    cubit = SettingsCubit(repository: repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('uses system theme by default', () async {
    await cubit.load();

    expect(cubit.state.theme, ThemePreference.system);

    expect(cubit.state.status, SettingsStatus.ready);
  });

  test('loads saved dark theme', () async {
    repository.storedTheme = ThemePreference.dark;

    await cubit.load();

    expect(cubit.state.theme, ThemePreference.dark);
  });

  test('changes and persists light theme', () async {
    await cubit.load();

    await cubit.setTheme(ThemePreference.light);

    expect(cubit.state.theme, ThemePreference.light);

    expect(repository.storedTheme, ThemePreference.light);
  });

  test('restores previous theme on save failure', () async {
    await cubit.load();

    repository.failOnSave = true;

    await cubit.setTheme(ThemePreference.dark);

    expect(cubit.state.theme, ThemePreference.system);

    expect(cubit.state.error, isNotNull);
    expect(cubit.state.isSaving, isFalse);
  });

  test('handles loading failure and retries', () async {
    repository.failOnLoad = true;

    await cubit.load();

    expect(cubit.state.status, SettingsStatus.failure);

    repository.failOnLoad = false;

    await cubit.load();

    expect(cubit.state.status, SettingsStatus.ready);
  });

  test('restores saved theme in a new Cubit', () async {
    await cubit.load();

    await cubit.setTheme(ThemePreference.dark);

    final restored = SettingsCubit(repository: repository);

    try {
      await restored.load();

      expect(restored.state.theme, ThemePreference.dark);
    } finally {
      await restored.close();
    }
  });
}
