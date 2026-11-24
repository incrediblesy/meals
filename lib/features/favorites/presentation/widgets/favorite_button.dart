import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  final MealEntity meal;

  const FavoriteButton({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.contains(meal.id);

        final label = isFavorite ? 'Remove from favorites' : 'Add to favorites';

        return IconButton(
          tooltip: label,
          isSelected: isFavorite,

          style: IconButton.styleFrom(
            backgroundColor: colors.surfaceContainerHigh,
            foregroundColor: colors.onSurfaceVariant,
          ),

          icon: const Icon(Icons.favorite_border_rounded),

          selectedIcon: Icon(Icons.favorite_rounded, color: colors.error),

          onPressed: !state.canModify
              ? null
              : () async {
                  final success = await context.read<FavoritesCubit>().toggle(
                    meal,
                  );

                  if (!context.mounted) return;

                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to save changes.')),
                    );
                  }
                },
        );
      },
    );
  }
}
