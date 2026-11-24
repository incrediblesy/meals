import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/widgets/meal_item_widget.dart';

class MealListPageArguments {
  final MealsEvent event;
  final String title;
  MealListPageArguments({required this.event, required this.title});
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
    _retry();
  }

  void _retry() => context.read<MealsBloc>().add(widget.arguments.event);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.arguments.title)),
      body: BlocBuilder<MealsBloc, MealsState>(
        builder: (context, state) {
          if (state is MealsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load recipes.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          if (state is! MealsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.meals.isEmpty) {
            return const Center(
              child: Text('No recipes found. Try another search.'),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.meals.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, index) =>
                    MealItemWidget(meal: state.meals[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
