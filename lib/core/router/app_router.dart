import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/di/injector.dart';
import 'package:meals/features/categories/presentation/pages/categories_page.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/pages/home_page.dart';
import 'package:meals/features/meals/presentation/pages/meal_details_page.dart';
import 'package:meals/features/meals/presentation/pages/meal_list_page.dart';

class AppRouter {
  static const initialRoute = '/';
  static const categoryListRoute = '/categories';
  static const mealListRoute = '/meals';
  static const mealDetailsRoute = '/meal-details';

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => const HomePage());
      case categoryListRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Categories')),
          body: const CategoriesPage(),
        ));
      case mealListRoute:
        final arguments = settings.arguments;
        if (arguments is! MealListPageArguments) return _invalidRoute(settings);
        return MaterialPageRoute(settings: settings, builder: (_) => BlocProvider(
          create: (_) => sl<MealsBloc>(),
          child: MealListPage(arguments: arguments),
        ));
      case mealDetailsRoute:
        final id = settings.arguments;
        if (id is! String || id.trim().isEmpty) return _invalidRoute(settings);
        return MaterialPageRoute(settings: settings, builder: (_) => BlocProvider(
          create: (_) => sl<MealsBloc>(),
          child: MealDetailsPage(id: id),
        ));
      default:
        return _invalidRoute(settings);
    }
  }

  Route<dynamic> _invalidRoute(RouteSettings settings) => MaterialPageRoute(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Page unavailable')),
      body: const Center(child: Text('This page could not be opened.')),
    ),
  );
}
