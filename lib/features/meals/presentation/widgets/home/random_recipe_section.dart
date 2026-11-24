import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';

class RandomRecipeSection extends StatelessWidget {
  final VoidCallback onSurprise;

  const RandomRecipeSection({super.key, required this.onSurprise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              Icons.shuffle_rounded,
              size: 28,
              color: colors.onPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Not sure what to cook?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Discover a random recipe and try '
            'something different today.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          BlocBuilder<MealsBloc, MealsState>(
            builder: (context, state) {
              final isLoading = state is MealsLoading || state is MealsInitial;

              return FilledButton.icon(
                onPressed: isLoading ? null : onSurprise,
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Surprise me'),
              );
            },
          ),
        ],
      ),
    );
  }
}
