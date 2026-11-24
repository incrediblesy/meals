import 'package:bloc/bloc.dart';

import 'package:meals/features/settings/domain/repositories/settings_repository.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit({required this.repository}) : super(const SettingsState());

  // ================= LOAD SETTINGS =================

  Future<void> load() async {
    if (isClosed ||
        state.status == SettingsStatus.loading ||
        state.status == SettingsStatus.ready) {
      return;
    }

    emit(SettingsState(theme: state.theme, status: SettingsStatus.loading));

    try {
      final theme = await repository.loadTheme();

      if (isClosed) return;

      emit(SettingsState(theme: theme, status: SettingsStatus.ready));
    } catch (_) {
      if (isClosed) return;

      emit(
        const SettingsState(
          status: SettingsStatus.failure,
          error: 'Unable to load preferences.',
        ),
      );
    }
  }

  // ================= CHANGE THEME =================

  Future<void> setTheme(ThemePreference theme) async {
    if (isClosed || !state.canModify || state.theme == theme) {
      return;
    }

    final previousTheme = state.theme;

    // Update the interface immediately.
    emit(
      SettingsState(theme: theme, status: SettingsStatus.ready, isSaving: true),
    );

    try {
      await repository.saveTheme(theme);

      if (isClosed) return;

      emit(SettingsState(theme: theme, status: SettingsStatus.ready));
    } catch (_) {
      if (isClosed) return;

      // Restore the previous theme if saving fails.
      emit(
        SettingsState(
          theme: previousTheme,
          status: SettingsStatus.ready,
          error: 'Unable to save appearance settings.',
        ),
      );
    }
  }
}
