import 'package:material_ui/material_ui.dart';
import 'package:meals/core/di/injector.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = sl<AppTheme>();
    final router = sl<AppRouter>();

    return MaterialApp(
      title: 'Meals',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: router.generateRoute,
    );
  }
}
