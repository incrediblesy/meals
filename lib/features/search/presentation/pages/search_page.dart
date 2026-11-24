import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/features/meals/presentation/widgets/meal_grid_skeleton.dart';

import '../../domain/entities/search_history_entry.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../cubit/search_history_cubit.dart';

import '../widgets/search_input.dart';
import '../widgets/search_mode_selector.dart';
import '../widgets/search_results.dart';
import '../widgets/search_suggestions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  SearchCubit get _cubit => context.read<SearchCubit>();

  SearchHistoryCubit get _history => context.read<SearchHistoryCubit>();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: _cubit.state.query);

    if (_controller.text.trim().length >= 2) {
      _recordSearch();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recordSearch() {
    final query = _controller.text.trim();

    if (query.length < 2) return;

    unawaited(_history.record(query: query, mode: _cubit.state.mode.name));
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    _recordSearch();

    _cubit.updateQuery(_controller.text, immediate: true);
  }

  void _clear() {
    _controller.clear();
    _cubit.clear();
  }

  void _changeMode(SearchMode mode) {
    if (_cubit.state.mode == mode) return;

    _controller.clear();
    _cubit.changeMode(mode);
  }

  void _selectSuggestion(String value) {
    _controller.text = value;
    _submit();
  }

  void _selectHistory(SearchHistoryEntry entry) {
    SearchMode mode = SearchMode.name;

    for (final value in SearchMode.values) {
      if (value.name == entry.mode) {
        mode = value;
        break;
      }
    }

    _changeMode(mode);

    _controller.text = entry.query;

    _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search recipes')),

      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxContentWidth,
            ),

            child: SizedBox.expand(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(state),

                      const Divider(),

                      Expanded(child: _content(state)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(SearchState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find your next meal', style: theme.textTheme.headlineSmall),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Search by recipe, category, cuisine or ingredient.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          SearchInput(
            controller: _controller,
            state: state,
            onChanged: (value) => _cubit.updateQuery(value),
            onSubmit: _submit,
            onClear: _clear,
          ),

          const SizedBox(height: AppSpacing.lg),

          SearchModeSelector(mode: state.mode, onChanged: _changeMode),
        ],
      ),
    );
  }

  Widget _content(SearchState state) {
    return switch (state.status) {
      SearchStatus.idle => SearchSuggestions(
        state: state,
        onSelected: _selectSuggestion,
        onHistorySelected: _selectHistory,
      ),

      SearchStatus.loading => const MealGridSkeleton(
        label: 'Searching recipes',
      ),

      SearchStatus.success => SearchResults(state: state),

      SearchStatus.empty => AppEmpty(
        icon: Icons.search_off_rounded,
        title: 'No recipes found',
        message: 'No results for "${state.query}". Try another search.',
        actionLabel: 'Clear search',
        onAction: _clear,
      ),

      SearchStatus.failure => AppError(
        title: 'Search failed',
        message: state.failure?.message ?? 'Unable to search for recipes.',
        onRetry: _cubit.retry,
      ),
    };
  }
}
