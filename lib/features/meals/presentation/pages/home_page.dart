import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/features/categories/presentation/pages/categories_page.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/pages/meal_list_page.dart';
import 'package:meals/features/meals/presentation/widgets/meal_banner_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _shuffle() => context.read<MealsBloc>().add(LookupRandomMeal());
  void _openList(MealsEvent event, String title) =>
      Navigator.of(context).pushNamed(
        AppRouter.mealListRoute,
        arguments: MealListPageArguments(event: event, title: title),
      );
  void _submit(String input) {
    final name = input.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    _openList(SearchMealsByName(name), 'Results for "$name"');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        return Scaffold(
          appBar: AppBar(title: const Text('Meals')),
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('Discover'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view),
                      label: Text('Categories'),
                    ),
                  ],
                ),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: [_discover(), const CategoriesPage()],
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view),
                      label: 'Categories',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _discover() {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'What are we cooking?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find something delicious to make today.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'Search recipes',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _submit(_search.text),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recipe inspiration',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                BlocBuilder<MealsBloc, MealsState>(
                  builder: (_, state) => IconButton(
                    tooltip: 'Show another recipe',
                    onPressed: state is MealsLoading ? null : _shuffle,
                    icon: const Icon(Icons.shuffle),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<MealsBloc, MealsState>(
              builder: (_, state) {
                if (state is RandomMealLoaded) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: MealBannerWidget(meal: state.meal),
                  );
                }
                if (state is MealsError) {
                  return SizedBox(
                    height: 180,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Could not load recipe inspiration.'),
                          TextButton(
                            onPressed: _shuffle,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Browse by letter',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                  .split('')
                  .map(
                    (letter) => ActionChip(
                      label: Text(letter),
                      onPressed: () => _openList(
                        ListMealsByFirstLetter(letter),
                        'Recipes starting with $letter',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
