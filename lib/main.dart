import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'package:meals/app.dart';
import 'package:meals/core/di/injector.dart';
import 'package:meals/features/categories/presentation/bloc/categories_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  init();

  if (!kIsWeb && _isDesktop) {
    final window = WindowManager.instance.getCurrent()!;

    window.title = 'Meals';
    window.setSize(const Size(600, 800).toNative(), false);
    window.minimumSize = const Size(300, 400).toNative();
    window.center();
    window.show();
  }

  runApp(
    BlocProvider<CategoriesBloc>(
      create: (_) => sl<CategoriesBloc>()..add(FetchCategories()),
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
