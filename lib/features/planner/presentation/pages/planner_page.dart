import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';

import 'package:meals/features/shopping/presentation/cubit/shopping_cubit.dart';
import 'package:meals/features/shopping/presentation/cubit/shopping_state.dart';

import '../../domain/entities/planned_meal.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import '../widgets/planner_day_card.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  DateTime _weekStart = startOfWeek(DateTime.now());

  void _changeWeek(int direction) {
    setState(() {
      _weekStart = addCalendarDays(_weekStart, direction * 7);
    });
  }

  void _goToToday() {
    setState(() {
      _weekStart = startOfWeek(DateTime.now());
    });
  }

  void _findRecipes() {
    Navigator.of(context).pushNamed(AppRouter.searchRoute);
  }

  void _openRecipe(PlannedMeal entry) {
    Navigator.of(context)
        .pushNamed(AppRouter.mealDetailsRoute, arguments: entry.meal.id);
  }

  Future<void> _generateShoppingList(List<PlannedMeal> entries) async {
    final cubit = context.read<ShoppingCubit>();

    final success = await cubit.addMeals(entries.map((entry) => entry.meal));

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Weekly ingredients added to shopping list.'
              : 'Unable to generate shopping list.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        return switch (state.status) {
          PlannerStatus.initial || PlannerStatus.loading => const AppLoading(
            message: 'Loading meal planner...',
          ),

          PlannerStatus.failure => AppError(
            title: 'Meal planner unavailable',
            message: state.error ?? 'Unable to load meal plan.',
            onRetry: context.read<PlannerCubit>().load,
          ),

          PlannerStatus.ready => _buildContent(state),
        };
      },
    );
  }

  Widget _buildContent(PlannerState state) {
    final entries = state.mealsForWeek(_weekStart);

    final hasIngredients = entries.any(
      (entry) => entry.meal.ingredients.any(
        (ingredient) => ingredient.trim().isNotEmpty,
      ),
    );

    return ListView(
      key: const PageStorageKey<String>('planner-page'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildHeader(),

        const SizedBox(height: AppSpacing.xl),

        _buildWeekNavigation(),

        const SizedBox(height: AppSpacing.lg),

        _buildProgress(entries.length),

        const SizedBox(height: AppSpacing.lg),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: _findRecipes,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Find recipes'),
            ),

            BlocBuilder<ShoppingCubit, ShoppingState>(
              builder: (context, shoppingState) {
                return OutlinedButton.icon(
                  onPressed:
                      hasIngredients &&
                          state.canModify &&
                          shoppingState.canModify
                      ? () => _generateShoppingList(entries)
                      : null,

                  icon: const Icon(Icons.add_shopping_cart_rounded),

                  label: const Text('Generate shopping list'),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          'Open a recipe and select Add to meal plan '
          'to fill your weekly schedule.',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        if (state.isSaving) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
        ],

        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),

          Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        _buildWeek(state),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLAN AHEAD',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text('Meal planner', style: theme.textTheme.headlineMedium),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Organize your meals for the entire week.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation() {
    final localizations = MaterialLocalizations.of(context);

    final start = localizations.formatCompactDate(_weekStart);

    final end = localizations.formatCompactDate(addCalendarDays(_weekStart, 6));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous week',
                  onPressed: () => _changeWeek(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),

                Expanded(
                  child: Text(
                    '$start – $end',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                IconButton(
                  tooltip: 'Next week',
                  onPressed: () => _changeWeek(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),

            TextButton.icon(
              onPressed: _goToToday,
              icon: const Icon(Icons.today_outlined),
              label: const Text('This week'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(int count) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final total = MealSlot.values.length * 7;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),

      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count of $total meals planned',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          LinearProgressIndicator(
            value: count / total,
            color: colors.primary,
            backgroundColor: colors.onPrimaryContainer.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  Widget _buildWeek(PlannerState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 2 : 1;

        final width =
            (constraints.maxWidth - AppSpacing.lg * (columns - 1)) / columns;

        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (var index = 0; index < 7; index++)
              SizedBox(
                width: width,
                child: _buildDay(state, addCalendarDays(_weekStart, index)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDay(PlannerState state, DateTime date) {
    return PlannerDayCard(
      key: ValueKey(plannerDateKey(date)),
      date: date,

      meals: state.meals.where((entry) => entry.date == date).toList(),

      enabled: state.canModify,

      onOpen: _openRecipe,

      onRemove: (entry) {
        context.read<PlannerCubit>().removeMeal(entry.id);
      },
    );
  }
}
