import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';

import '../widgets/home/alphabet_section.dart';
import '../widgets/home/category_preview_section.dart';
import '../widgets/home/featured_recipe_section.dart';
import '../widgets/home/random_recipe_section.dart';

class DiscoverPage extends StatefulWidget {
  final VoidCallback onViewCategories;
  final bool isActive;

  const DiscoverPage({
    super.key,
    required this.onViewCategories,
    required this.isActive,
  });

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchController = TextEditingController();

  Future<MealsState?>? _pendingRefresh;
  bool _openingRandomRecipe = false;

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

  // ================= SEARCH =================

  void _openSearch() {
    FocusScope.of(context).unfocus();

    Navigator.of(context).pushNamed(
      AppRouter.searchRoute,
      arguments: _searchController.text.trim(),
    );
  }

  // ================= RANDOM RECIPE =================

  Future<MealsState?> _requestRandomMeal() {
    return _pendingRefresh ??= _loadRandomMeal().whenComplete(() {
      _pendingRefresh = null;
    });
  }

  Future<MealsState?> _loadRandomMeal() async {
    final bloc = context.read<MealsBloc>();

    if (bloc.isClosed) return null;

    final completion = bloc.stream.firstWhere(
      (state) => state is RandomMealLoaded || state is MealsError,
    );

    if (bloc.state is! MealsLoading) {
      bloc.add(LookupRandomMeal());
    }

    try {
      return await completion;
    } on StateError {
      // The route may have been disposed.
      return null;
    }
  }

  Future<void> _refreshFeatured() async {
    await _requestRandomMeal();
  }

  Future<void> _openRandomRecipe() async {
    if (_openingRandomRecipe) return;

    _openingRandomRecipe = true;

    try {
      final result = await _requestRandomMeal();

      if (!mounted || !widget.isActive) return;

      if (ModalRoute.of(context)?.isCurrent != true) {
        return;
      }

      if (result is RandomMealLoaded) {
        Navigator.of(context)
            .pushNamed(AppRouter.mealDetailsRoute, arguments: result.meal.id);
      }
    } finally {
      _openingRandomRecipe = false;
    }
  }

  // ================= PAGE =================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.tablet;

        final padding = isWide ? AppSpacing.xxl : AppSpacing.lg;

        return RefreshIndicator(
          onRefresh: _refreshFeatured,
          child: ListView(
            key: const PageStorageKey<String>('discover-page'),
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

              FeaturedRecipeSection(onRefresh: _refreshFeatured),

              const SizedBox(height: AppSpacing.xxl),

              CategoryPreviewSection(onViewAll: widget.onViewCategories),

              const SizedBox(height: AppSpacing.xxl),

              RandomRecipeSection(onSurprise: _openRandomRecipe),

              const SizedBox(height: AppSpacing.xxl),

              const AlphabetSection(),
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

  // ================= SEARCH FIELD =================

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
}
