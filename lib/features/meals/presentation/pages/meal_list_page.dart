import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';

import '../bloc/meals_bloc.dart';
import '../widgets/meal_grid.dart';

class MealListPageArguments {
  final MealsEvent event;
  final String title;
  const MealListPageArguments({required this.event, required this.title});
}

class MealListPage extends StatefulWidget {
  final MealListPageArguments arguments;
  const MealListPage({super.key, required this.arguments});

  @override
  State<MealListPage> createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => context.read<MealsBloc>().add(widget.arguments.event);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.arguments.title)),
      body: BlocBuilder<MealsBloc, MealsState>(
        builder: (context, state) {
          if (state is MealsLoaded && state.meals.isNotEmpty) {
            return MealGrid(
              meals: state.meals,
              scrollKey: const PageStorageKey<String>('meal-list-grid'),
            );
          }
          if ((state is MealsLoaded && state.meals.isEmpty) ||
              (state is MealsError && state.failure is EmptyResultFailure)) {
            return const AppEmpty(
              icon: Icons.search_off_rounded,
              title: 'No meals found',
            );
          }
          if (state is MealsError) {
            return AppError(message: state.message, onRetry: _load);
          }
          return const AppLoading(message: 'Loading recipes...');
        },
      ),
    );
  }
}
