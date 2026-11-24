import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';
import 'package:meals/features/meals/presentation/widgets/meal_item_widget.dart';

import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  final VoidCallback? onDiscover;

  const FavoritesPage({super.key, this.onDiscover});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        return switch (state.status) {
          FavoritesStatus.initial || FavoritesStatus.loading =>
            const AppLoading(message: 'Loading favorites...'),

          FavoritesStatus.failure => AppError(
            title: 'Favorites unavailable',
            message: state.error ?? 'Unable to load saved recipes.',
            onRetry: () {
              context.read<FavoritesCubit>().load();
            },
          ),

          FavoritesStatus.ready => _buildContent(context, state),
        };
      },
    );
  }

  Widget _buildContent(BuildContext context, FavoritesState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR COLLECTION',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text('Favorites', style: theme.textTheme.headlineMedium),

              const SizedBox(height: AppSpacing.sm),

              Text(
                state.count == 1
                    ? '1 saved recipe'
                    : '${state.count} saved recipes',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        if (state.isSaving)
          const LinearProgressIndicator(minHeight: 2)
        else
          const SizedBox(height: 2),

        Expanded(
          child: state.meals.isEmpty
              ? AppEmpty(
                  icon: Icons.favorite_border_rounded,
                  title: 'No favorites yet',
                  message:
                      'Save recipes you love and find '
                      'them here whenever you need them.',
                  actionLabel: 'Discover recipes',
                  onAction: onDiscover,
                )
              : GridView.builder(
                  key: const PageStorageKey<String>('favorites-grid'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  itemCount: state.meals.length,

                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                  ),

                  itemBuilder: (context, index) {
                    final meal = state.meals[index];

                    return MealItemWidget(key: ValueKey(meal.id), meal: meal);
                  },
                ),
        ),
      ],
    );
  }
}
