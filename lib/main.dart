import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:meals/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:meals/features/shopping/presentation/cubit/shopping_cubit.dart';
import 'package:window_manager/window_manager.dart';

import 'package:meals/app.dart';
import 'package:meals/core/di/injector.dart';

import 'package:meals/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:meals/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:meals/features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  init();

  final settingsCubit = sl<SettingsCubit>();

  await settingsCubit.load();

  if (!kIsWeb && _isDesktop) {
    final window = WindowManager.instance.getCurrent();

    if (window != null) {
      window.title = 'Meals';

      window.setSize(const Size(600, 800).toNative(), false);

      window.minimumSize = const Size(300, 400).toNative();

      window.center();
      window.show();
    }
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(lazy: false, create: (_) => settingsCubit),

        BlocProvider<CategoriesBloc>(
          create: (_) => sl<CategoriesBloc>()..add(FetchCategories()),
        ),

        BlocProvider<FavoritesCubit>(
          lazy: false,
          create: (_) => sl<FavoritesCubit>()..load(),
        ),

        BlocProvider<ShoppingCubit>(
          lazy: false,
          create: (_) => sl<ShoppingCubit>()..load(),
        ),

        BlocProvider<PlannerCubit>(
          lazy: false,
          create: (_) => sl<PlannerCubit>()..load(),
        ),

        BlocProvider<SearchHistoryCubit>(
          lazy: false,
          create: (_) => sl<SearchHistoryCubit>()..load(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

bool get _isDesktop {
  return switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}
