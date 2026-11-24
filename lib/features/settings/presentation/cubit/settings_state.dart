import 'package:equatable/equatable.dart';

import 'package:meals/features/settings/domain/repositories/settings_repository.dart';

enum SettingsStatus { initial, loading, ready, failure }

class SettingsState extends Equatable {
  final ThemePreference theme;
  final SettingsStatus status;
  final bool isSaving;
  final String? error;

  const SettingsState({
    this.theme = ThemePreference.system,
    this.status = SettingsStatus.initial,
    this.isSaving = false,
    this.error,
  });

  bool get canModify => status == SettingsStatus.ready && !isSaving;

  @override
  List<Object?> get props => [theme, status, isSaving, error];
}
