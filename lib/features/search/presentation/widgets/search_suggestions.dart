import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/features/search/domain/entities/search_history_entry.dart';
import 'package:meals/features/search/presentation/widgets/recent_searches.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchSuggestions extends StatefulWidget {
  final SearchState state;
  final ValueChanged<String> onSelected;
  final ValueChanged<SearchHistoryEntry> onHistorySelected;
  const SearchSuggestions({
    super.key,
    required this.state,
    required this.onSelected,
    required this.onHistorySelected,
  });

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  Future<List<String>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SearchSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.mode != widget.state.mode ||
        oldWidget.state.query != widget.state.query) {
      _load();
    }
  }

  void _load() {
    final state = widget.state;
    _future = state.mode == SearchMode.name
        ? null
        : context.read<SearchCubit>().filterSuggestions(
            state.mode,
            state.query,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isName = widget.state.mode == SearchMode.name;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          if (widget.state.query.isEmpty)
            RecentSearches(onSelected: widget.onHistorySelected),
          Icon(
            Icons.travel_explore_rounded,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Discover something delicious',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isName
                ? 'Enter a recipe name or choose a suggestion.'
                : 'Enter a filter name and select a matching suggestion.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isName ? 'Try searching for' : 'Available filters',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isName)
            _chips(const ['Chicken', 'Pasta', 'Soup', 'Salad', 'Pizza'])
          else
            FutureBuilder<List<String>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return AppError(
                    title: 'Filters unavailable',
                    message: 'Unable to load available filters.',
                    onRetry: () => setState(_load),
                  );
                }
                final suggestions = snapshot.data ?? const <String>[];
                if (suggestions.isEmpty) {
                  return const Text('No matching filters. Try another value.');
                }
                return _chips(suggestions);
              },
            ),
        ],
      ),
    );
  }

  Widget _chips(List<String> suggestions) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: suggestions
        .map(
          (value) => ActionChip(
            avatar: const Icon(Icons.search_rounded, size: 18),
            label: Text(value),
            onPressed: () => widget.onSelected(value),
          ),
        )
        .toList(),
  );
}
