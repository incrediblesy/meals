import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';

import '../../domain/entities/search_history_entry.dart';
import '../cubit/search_history_cubit.dart';

class RecentSearches extends StatelessWidget {
  final ValueChanged<SearchHistoryEntry> onSelected;

  const RecentSearches({super.key, required this.onSelected});

  IconData _modeIcon(String mode) {
    return switch (mode) {
      'category' => Icons.grid_view_outlined,
      'cuisine' => Icons.public_rounded,
      'ingredient' => Icons.shopping_basket_outlined,
      _ => Icons.search_rounded,
    };
  }

  String _modeLabel(String mode) {
    return switch (mode) {
      'category' => 'Category',
      'cuisine' => 'Cuisine',
      'ingredient' => 'Ingredient',
      _ => 'Recipe name',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
      builder: (context, state) {
        final cubit = context.read<SearchHistoryCubit>();

        if (state.isLoading) {
          return const LinearProgressIndicator();
        }

        if (state.entries.isEmpty && state.error == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.entries.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent searches',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),

                  TextButton(
                    onPressed: cubit.clear,
                    child: const Text('Clear all'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < state.entries.length; i++) ...[
                      if (i > 0) const Divider(height: 1),

                      _buildEntry(context, state.entries[i], cubit),
                    ],
                  ],
                ),
              ),
            ],

            if (state.error != null) ...[
              const SizedBox(height: AppSpacing.sm),

              Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),

              if (!state.isReady)
                TextButton(
                  onPressed: cubit.load,
                  child: const Text('Try again'),
                ),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }

  Widget _buildEntry(
    BuildContext context,
    SearchHistoryEntry entry,
    SearchHistoryCubit cubit,
  ) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      key: ValueKey(entry.id),

      leading: Icon(_modeIcon(entry.mode), color: colors.onSurfaceVariant),

      title: Text(entry.query, maxLines: 1, overflow: TextOverflow.ellipsis),

      subtitle: Text(_modeLabel(entry.mode)),

      onTap: () => onSelected(entry),

      trailing: IconButton(
        tooltip: 'Remove from history',
        onPressed: () => cubit.remove(entry.id),
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}
