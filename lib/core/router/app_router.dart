import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/di/injector.dart';
import 'package:meals/features/categories/presentation/pages/categories_page.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/pages/home_page.dart';
import 'package:meals/features/meals/presentation/pages/meal_details_page.dart';
import 'package:meals/features/meals/presentation/pages/meal_list_page.dart';
import 'package:meals/features/search/presentation/cubit/search_cubit.dart';
import 'package:meals/features/search/presentation/pages/search_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String categoryListRoute = '/categories';
  static const String mealListRoute = '/meals';
  static const String mealDetailsRoute = '/meal-details';
  static const String searchRoute = '/search';

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return _mealsRoute(settings, const HomePage());

      case categoryListRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Categories')),
            body: const CategoriesPage(),
          ),
        );

      case mealListRoute:
        final arguments = settings.arguments;

        if (arguments is! MealListPageArguments) {
          return _errorRoute(settings, 'Invalid meal list arguments');
        }

        return _mealsRoute(settings, MealListPage(arguments: arguments));

      case mealDetailsRoute:
        final id = settings.arguments;

        if (id is! String || id.trim().isEmpty) {
          return _errorRoute(settings, 'Invalid meal ID');
        }

        return _mealsRoute(settings, MealDetailsPage(id: id));

      case searchRoute:
        final query = settings.arguments;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<SearchCubit>(
            create: (_) {
              final cubit = sl<SearchCubit>();

              if (query is String && query.trim().isNotEmpty) {
                cubit.updateQuery(query, immediate: true);
              }

              return cubit;
            },
            child: const SearchPage(),
          ),
        );

      default:
        return _errorRoute(settings, 'Route not found: ${settings.name}');
    }
  }

  MaterialPageRoute<dynamic> _mealsRoute(RouteSettings settings, Widget page) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) =>
          BlocProvider<MealsBloc>(create: (_) => sl<MealsBloc>(), child: page),
    );
  }

  MaterialPageRoute<dynamic> _errorRoute(
    RouteSettings settings,
    String message,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page unavailable')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
