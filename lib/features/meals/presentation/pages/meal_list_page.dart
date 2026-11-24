import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/widgets/meal_item_widget.dart';

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
    _loadMeals();
  }

  void _loadMeals() {
    context.read<MealsBloc>().add(widget.arguments.event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.arguments.title)),
      body: BlocBuilder<MealsBloc, MealsState>(
        builder: (context, state) {
          if (state is MealsLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.meals.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return MealItemWidget(meal: state.meals[index]);
              },
            );
          }

          if (state is MealsError) {
            final isEmpty = state.failure is EmptyResultFailure;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEmpty ? Icons.search_off : Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    if (!isEmpty) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadMeals,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
