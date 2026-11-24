import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';
import 'package:meals/features/planner/presentation/widgets/add_to_planner_button.dart';
import 'package:meals/features/shopping/presentation/widgets/add_to_shopping_button.dart';

import '../../domain/entities/meal_entity.dart';

import '../bloc/meals_bloc.dart';

import '../widgets/cooking/cooking_steps.dart';

import '../widgets/details/ingredients_section.dart';
import '../widgets/details/instructions_section.dart';
import '../widgets/details/recipe_header.dart';
import '../widgets/details/recipe_links.dart';
import '../widgets/details/recipe_metadata.dart';

import 'cooking_page.dart';

class MealDetailsPage extends StatefulWidget {
  final String id;

  const MealDetailsPage({super.key, required this.id});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  final Set<int> _checked = {};

  @override
  void initState() {
    super.initState();

    _load();
  }

  @override
  void didUpdateWidget(covariant MealDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id) {
      _checked.clear();

      _load();
    }
  }

  void _load() {
    context.read<MealsBloc>().add(GetMealById(widget.id));
  }

  void _toggle(int index) {
    setState(() {
      if (!_checked.add(index)) {
        _checked.remove(index);
      }
    });
  }

  void _startCooking(MealEntity meal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CookingPage(meal: meal, preparedIngredients: Set.of(_checked)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        if (state is MealLoaded && state.meal.id == widget.id) {
          return _recipe(state.meal);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Recipe')),

          body: state is MealsError
              ? AppError(
                  title: 'Unable to load recipe',
                  message: state.message,
                  onRetry: _load,
                )
              : const AppLoading(message: 'Loading recipe...'),
        );
      },
    );
  }

  Widget _recipe(MealEntity meal) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RecipeHeader(meal: meal),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxContentWidth,
                ),

                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),

                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final ingredients = IngredientsSection(
                        meal: meal,
                        checked: _checked,
                        onToggle: _toggle,
                        onReset: () => setState(_checked.clear),
                      );

                      final instructions = InstructionsSection(
                        instructions: meal.instructions,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RecipeMetadata(meal: meal),

                          if (parseCookingSteps(meal.instructions)
                              .isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),

                            SizedBox(
                              width: double.infinity,

                              child: FilledButton.icon(
                                onPressed: () => _startCooking(meal),

                                icon: const Icon(Icons.play_arrow_rounded),

                                label: const Text('Start cooking'),
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xxl),

                          if (constraints.maxWidth >= 900)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: ingredients),

                                const SizedBox(width: AppSpacing.xxl),

                                Expanded(flex: 3, child: instructions),
                              ],
                            )
                          else ...[
                            ingredients,

                            const SizedBox(height: AppSpacing.xxl),

                            instructions,
                          ],

                          if (meal.ingredients.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),

                            AddToShoppingButton(meal: meal),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          AddToPlannerButton(meal: meal),

                          const SizedBox(height: AppSpacing.xxl),

                          RecipeLinks(video: meal.youtube, source: meal.source),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
