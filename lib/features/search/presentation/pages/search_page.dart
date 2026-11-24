import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';

import 'package:meals/features/meals/presentation/widgets/meal_item_widget.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: context.read<SearchCubit>().state.query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // ================= ACTIONS =================

  void _submitSearch() {
    FocusScope.of(context).unfocus();

    context.read<SearchCubit>().updateQuery(_controller.text, immediate: true);
  }

  void _clearSearch() {
    _controller.clear();
    context.read<SearchCubit>().clear();
  }

  void _changeMode(SearchMode mode) {
    final cubit = context.read<SearchCubit>();

    if (cubit.state.mode == mode) return;

    _controller.clear();
    cubit.changeMode(mode);
  }

  void _searchExample(String value) {
    _controller.text = value;
    _submitSearch();
  }

  // ================= PAGE =================

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
            child: SizedBox(
              width: double.infinity,
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearchHeader(state),

                      const Divider(),

                      Expanded(child: _buildContent(state)),
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

  // ================= SEARCH HEADER =================

  Widget _buildSearchHeader(SearchState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find your next meal', style: theme.textTheme.headlineSmall),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Search by recipe, category, cuisine '
            'or ingredient.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          _buildSearchField(state),

          const SizedBox(height: AppSpacing.lg),

          _buildSearchModes(state.mode),
        ],
      ),
    );
  }

  // ================= SEARCH FIELD =================

  Widget _buildSearchField(SearchState state) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,

            onChanged: (value) {
              context.read<SearchCubit>().updateQuery(value);
            },

            onSubmitted: (_) => _submitSearch(),

            decoration: InputDecoration(
              hintText: _getHint(state.mode),
              prefixIcon: const Icon(Icons.search_rounded),

              suffixIcon: state.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        IconButton.filled(
          tooltip: 'Search',
          onPressed: state.query.length < 2 ? null : _submitSearch,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    );
  }

  // ================= SEARCH MODES =================

  Widget _buildSearchModes(SearchMode selectedMode) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _buildModeChip(
          mode: SearchMode.name,
          selectedMode: selectedMode,
          label: 'Name',
          icon: Icons.search_rounded,
        ),

        _buildModeChip(
          mode: SearchMode.category,
          selectedMode: selectedMode,
          label: 'Category',
          icon: Icons.grid_view_rounded,
        ),

        _buildModeChip(
          mode: SearchMode.cuisine,
          selectedMode: selectedMode,
          label: 'Cuisine',
          icon: Icons.public_rounded,
        ),

        _buildModeChip(
          mode: SearchMode.ingredient,
          selectedMode: selectedMode,
          label: 'Ingredient',
          icon: Icons.shopping_basket_outlined,
        ),
      ],
    );
  }

  Widget _buildModeChip({
    required SearchMode mode,
    required SearchMode selectedMode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = mode == selectedMode;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,

      avatar: Icon(icon, size: 18),

      label: Text(label),

      onSelected: (selected) {
        if (selected) {
          _changeMode(mode);
        }
      },
    );
  }

  // ================= CONTENT =================

  Widget _buildContent(SearchState state) {
    return switch (state.status) {
      SearchStatus.idle => _buildIdleState(state),

      SearchStatus.loading => const AppLoading(message: 'Searching recipes...'),

      SearchStatus.success => _buildResults(state),

      SearchStatus.empty => AppEmpty(
        icon: Icons.search_off_rounded,
        title: 'No recipes found',
        message:
            'No results for "${state.query}". '
            'Try another search.',
        actionLabel: 'Clear search',
        onAction: _clearSearch,
      ),

      SearchStatus.failure => AppError(
        title: 'Search failed',
        message: state.failure?.message ?? 'Unable to search for recipes.',
        onRetry: context.read<SearchCubit>().retry,
      ),
    };
  }

  // ================= EMPTY SEARCH =================

  Widget _buildIdleState(SearchState state) {
    final theme = Theme.of(context);
    final isNameSearch = state.mode == SearchMode.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

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
            isNameSearch
                ? 'Enter a recipe name or choose a suggestion.'
                : 'Enter a filter name and select a matching suggestion.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            isNameSearch ? 'Try searching for' : 'Available filters',
            style: theme.textTheme.titleMedium,
          ),

          const SizedBox(height: AppSpacing.md),

          if (isNameSearch)
            _buildSuggestionChips(_getExamples(state.mode))
          else
            FutureBuilder<List<String>>(
              key: ValueKey('${state.mode.name}-${state.query}'),
              future: context.read<SearchCubit>().filterSuggestions(
                state.mode,
                state.query,
              ),
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
                    onRetry: () => setState(() {}),
                  );
                }

                final suggestions = snapshot.data ?? const <String>[];

                if (suggestions.isEmpty) {
                  return Text(
                    'No matching filters. Try another value.',
                    style: theme.textTheme.bodyMedium,
                  );
                }

                return _buildSuggestionChips(suggestions);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(List<String> suggestions) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: suggestions.map((value) {
        return ActionChip(
          avatar: const Icon(Icons.search_rounded, size: 18),
          label: Text(value),
          onPressed: () => _searchExample(value),
        );
      }).toList(),
    );
  }

  // ================= RESULTS =================

  Widget _buildResults(SearchState state) {
    final theme = Theme.of(context);

    return CustomScrollView(
      key: PageStorageKey<String>('search-${state.mode.name}-${state.query}'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              '${state.meals.length} recipes found',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              childAspectRatio: 0.85,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
            ),

            delegate: SliverChildBuilderDelegate((context, index) {
              return MealItemWidget(meal: state.meals[index]);
            }, childCount: state.meals.length),
          ),
        ),
      ],
    );
  }

  // ================= SEARCH CONFIGURATION =================

  String _getHint(SearchMode mode) {
    return switch (mode) {
      SearchMode.name => 'Search recipes...',
      SearchMode.category => 'Search categories...',
      SearchMode.cuisine => 'Search cuisines...',
      SearchMode.ingredient => 'Search ingredients...',
    };
  }

  List<String> _getExamples(SearchMode mode) {
    return switch (mode) {
      SearchMode.name => ['Chicken', 'Pasta', 'Soup', 'Salad', 'Pizza'],

      SearchMode.category => [
        'Chicken',
        'Beef',
        'Seafood',
        'Dessert',
        'Vegetarian',
      ],

      SearchMode.cuisine => [
        'Italian',
        'Indian',
        'Japanese',
        'Mexican',
        'French',
      ],

      SearchMode.ingredient => [
        'Chicken breast',
        'Salmon',
        'Potatoes',
        'Rice',
        'Eggs',
      ],
    };
  }
}
