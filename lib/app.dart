import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/di/injector.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_theme.dart';

import 'package:meals/features/settings/domain/repositories/settings_repository.dart';
import 'package:meals/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:meals/features/settings/presentation/cubit/settings_state.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = sl<AppTheme>();
    final router = sl<AppRouter>();

    return BlocSelector<SettingsCubit, SettingsState, ThemePreference>(
      selector: (state) => state.theme,

      builder: (context, preference) {
        final themeMode = switch (preference) {
          ThemePreference.system => ThemeMode.system,
          ThemePreference.light => ThemeMode.light,
          ThemePreference.dark => ThemeMode.dark,
        };

        return MaterialApp(
          title: 'Meals',
          debugShowCheckedModeBanner: false,

          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: themeMode,

          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: router.generateRoute,
        );
      },
    );
  }
}
