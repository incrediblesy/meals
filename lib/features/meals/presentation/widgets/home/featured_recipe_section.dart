import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/widgets/meal_banner_widget.dart';

class FeaturedRecipeSection extends StatelessWidget {
  final VoidCallback onRefresh;

  const FeaturedRecipeSection({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        final isLoading = state is MealsLoading || state is MealsInitial;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured recipe',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Something new to try',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh featured recipe',
                  onPressed: isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            if (state is RandomMealLoaded)
              MealBannerWidget(meal: state.meal)
            else if (state is MealsError)
              Card(
                child: AppError(
                  title: 'Recipe unavailable',
                  message: state.message,
                  onRetry: onRefresh,
                ),
              )
            else
              const Card(
                child: SizedBox(
                  height: 280,
                  child: AppLoading(message: 'Finding a recipe...'),
                ),
              ),
          ],
        );
      },
    );
  }
}
