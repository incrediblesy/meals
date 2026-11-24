import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';

import 'package:meals/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:meals/features/categories/presentation/pages/categories_page.dart';
import 'package:meals/features/categories/presentation/widgets/category_item.dart';

import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/pages/meal_list_page.dart';
import 'package:meals/features/meals/presentation/widgets/meal_banner_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    context.read<MealsBloc>().add(LookupRandomMeal());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= ACTIONS =================

  void _selectTab(int index) {
    if (_selectedIndex == index) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSearch() {
    final query = _searchController.text.trim();

    FocusScope.of(context).unfocus();

    Navigator.of(context).pushNamed(AppRouter.searchRoute, arguments: query);
  }

  void _openMealsByLetter(String letter) {
    Navigator.of(context).pushNamed(
      AppRouter.mealListRoute,
      arguments: MealListPageArguments(
        event: ListMealsByFirstLetter(letter),
        title: 'Meals starting with $letter',
      ),
    );
  }

  void _reloadCategories() {
    context.read<CategoriesBloc>().add(FetchCategories());
  }

  Future<void> _refreshFeatured() async {
    final bloc = context.read<MealsBloc>();

    if (bloc.isClosed) return;

    final completion = bloc.stream.firstWhere(
      (state) => state is RandomMealLoaded || state is MealsError,
    );

    if (bloc.state is! MealsLoading) {
      bloc.add(LookupRandomMeal());
    }

    try {
      await completion;
    } on StateError {
      if (!bloc.isClosed) rethrow;
    }
  }

  // ================= APPLICATION SHELL =================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;

        return Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            top: false,
            bottom: isDesktop,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop) ...[
                  _buildNavigationRail(),
                  const VerticalDivider(width: 1, thickness: 1),
                ],

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppBreakpoints.maxContentWidth,
                      ),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          _buildDiscoverPage(),
                          const CategoriesPage(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isDesktop ? null : _buildNavigationBar(),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text('Meals'),
        ],
      ),
    );
  }

  // ================= MOBILE NAVIGATION =================

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _selectTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Categories',
        ),
      ],
    );
  }

  // ================= DESKTOP NAVIGATION =================

  Widget _buildNavigationRail() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 224,
      child: ColoredBox(
        color: colors.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'WORKSPACE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              _buildNavigationItem(
                index: 0,
                label: 'Discover',
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore_rounded,
              ),

              const SizedBox(height: AppSpacing.sm),

              _buildNavigationItem(
                index: 1,
                label: 'Categories',
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
              ),

              const Spacer(),

              const Divider(),

              const SizedBox(height: AppSpacing.lg),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meals', style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Recipe discovery',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isSelected = _selectedIndex == index;

    final foregroundColor = isSelected
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;

    final borderRadius = BorderRadius.circular(AppRadius.md);

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryContainer : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () => _selectTab(index),
            hoverColor: colors.primary.withValues(alpha: 0.06),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? selectedIcon : icon,
                      size: 24,
                      color: foregroundColor,
                    ),

                    const SizedBox(width: AppSpacing.md),

                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foregroundColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),

                    if (isSelected)
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= DISCOVER PAGE =================

  Widget _buildDiscoverPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.tablet;

        final padding = isWide ? AppSpacing.xxl : AppSpacing.lg;

        return RefreshIndicator(
          onRefresh: _refreshFeatured,
          child: ListView(
            key: const PageStorageKey('discover-page'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              padding,
              AppSpacing.xl,
              padding,
              AppSpacing.xxxl,
            ),
            children: [
              _buildWelcomeSection(isWide),
              const SizedBox(height: AppSpacing.xl),

              _buildSearchField(),
              const SizedBox(height: AppSpacing.xxl),

              _buildFeaturedSection(),
              const SizedBox(height: AppSpacing.xxl),

              _buildCategoriesSection(),
              const SizedBox(height: AppSpacing.xxl),

              _buildRandomRecipeSection(),
              const SizedBox(height: AppSpacing.xxl),

              _buildAlphabetSection(),
            ],
          ),
        );
      },
    );
  }

  // ================= WELCOME =================

  Widget _buildWelcomeSection(bool isWide) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISCOVER',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          'What would you like to cook?',
          style: isWide
              ? theme.textTheme.headlineLarge
              : theme.textTheme.headlineMedium,
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Discover recipes from around the world '
          'and find your next favorite meal.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ================= SEARCH =================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _openSearch(),
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Search',
          onPressed: _openSearch,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
    );
  }

  // ================= FEATURED RECIPE =================

  Widget _buildFeaturedSection() {
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        final isLoading = state is MealsLoading || state is MealsInitial;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Featured recipe',
              subtitle: 'Something new to try',
              action: IconButton(
                tooltip: 'Refresh featured recipe',
                onPressed: isLoading ? null : _refreshFeatured,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (state is RandomMealLoaded)
              MealBannerWidget(meal: state.meal)
            else if (state is MealsError)
              Card(
                child: AppError(
                  title: 'Recipe unavailable',
                  message: state.message,
                  onRetry: _refreshFeatured,
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

  // ================= CATEGORIES =================

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Explore categories',
          subtitle: 'Find recipes by food category',
          action: TextButton(
            onPressed: () => _selectTab(1),
            child: const Text('View all'),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesError) {
              return Card(
                child: AppError(
                  title: 'Categories unavailable',
                  message: state.message,
                  onRetry: _reloadCategories,
                ),
              );
            }

            if (state is CategoriesLoaded) {
              if (state.categories.isEmpty) {
                return const Card(
                  child: AppEmpty(
                    icon: Icons.category_outlined,
                    title: 'No categories found',
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = switch (constraints.maxWidth) {
                    >= 900 => 4,
                    >= 500 => 3,
                    _ => 2,
                  };

                  final categories = state.categories
                      .take(columns == 4 ? 8 : 6)
                      .toList(growable: false);

                  return GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 150,
                    ),
                    itemBuilder: (context, index) {
                      return CategoryItem(category: categories[index]);
                    },
                  );
                },
              );
            }

            return const Card(
              child: SizedBox(
                height: 160,
                child: AppLoading(message: 'Loading categories...'),
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= RANDOM DISCOVERY =================

  Widget _buildRandomRecipeSection() {
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
                onPressed: isLoading
                    ? null
                    : () async {
                        await _refreshFeatured();

                        if (!mounted || _selectedIndex != 0) {
                          return;
                        }

                        final result = context.read<MealsBloc>().state;

                        if (result is RandomMealLoaded) {
                          Navigator.of(context).pushNamed(
                            AppRouter.mealDetailsRoute,
                            arguments: result.meal.id,
                          );
                        }
                      },
                icon: const Icon(Icons.casino_outlined),
                label: const Text('Surprise me'),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= ALPHABETICAL BROWSING =================

  Widget _buildAlphabetSection() {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    return Card(
      child: ExpansionTile(
        key: const PageStorageKey<String>('alphabet-expansion'),
        leading: Icon(
          Icons.sort_by_alpha_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Browse A–Z'),
        subtitle: const Text('Find recipes by their first letter'),
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: alphabet.split('').map((letter) {
                return ActionChip(
                  label: SizedBox(
                    width: 24,
                    child: Text(letter, textAlign: TextAlign.center),
                  ),
                  onPressed: () {
                    _openMealsByLetter(letter);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SHARED SECTION HEADER =================

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.sm), action],
      ],
    );
  }
}
