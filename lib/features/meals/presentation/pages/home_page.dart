import 'package:material_ui/material_ui.dart';

import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';

import 'package:meals/features/categories/presentation/pages/categories_page.dart';
import 'package:meals/features/favorites/presentation/pages/favorites_page.dart';
import 'package:meals/features/planner/presentation/pages/planner_page.dart';
import 'package:meals/features/settings/presentation/pages/settings_page.dart';
import 'package:meals/features/shopping/presentation/pages/shopping_page.dart';

import '../widgets/home/home_keyboard_shortcuts.dart';
import '../widgets/home/home_navigation.dart';
import 'discover_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeTab _selectedTab = HomeTab.discover;

  final _shortcutFocus = FocusNode(debugLabel: 'Home keyboard shortcuts');

  @override
  void dispose() {
    _shortcutFocus.dispose();
    super.dispose();
  }

  void _selectTab(HomeTab tab) {
    if (_selectedTab == tab) return;

    _shortcutFocus.requestFocus();

    setState(() {
      _selectedTab = tab;
    });
  }

  void _openSearch() {
    if (ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pushNamed(AppRouter.searchRoute);
  }

  @override
  Widget build(BuildContext context) {
    return HomeKeyboardShortcuts(
      focusNode: _shortcutFocus,
      onSearch: _openSearch,
      onTabSelected: _selectTab,

      child: LayoutBuilder(
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
                    HomeSidebar(
                      selectedTab: _selectedTab,
                      onChanged: _selectTab,
                    ),

                    const VerticalDivider(width: 1, thickness: 1),
                  ],

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppBreakpoints.maxContentWidth,
                        ),

                        child: SizedBox.expand(child: _buildPages()),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            bottomNavigationBar: isDesktop
                ? null
                : HomeNavigationBar(
                    selectedTab: _selectedTab,
                    onChanged: _selectTab,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPage(HomeTab tab) {
    return switch (tab) {
      HomeTab.discover => DiscoverPage(
        isActive: _selectedTab == HomeTab.discover,
        onViewCategories: () {
          _selectTab(HomeTab.categories);
        },
      ),

      HomeTab.categories => const CategoriesPage(),

      HomeTab.favorites => FavoritesPage(
        onDiscover: () {
          _selectTab(HomeTab.discover);
        },
      ),

      HomeTab.shopping => const ShoppingPage(),

      HomeTab.planner => const PlannerPage(),

      HomeTab.settings => const SettingsPage(),
    };
  }

  Widget _buildPages() {
    return IndexedStack(
      index: _selectedTab.index,
      sizing: StackFit.expand,

      children: [
        for (final tab in HomeTab.values)
          TickerMode(
            key: ValueKey(tab),
            enabled: _selectedTab == tab,

            child: ExcludeFocus(
              excluding: _selectedTab != tab,
              child: _buildPage(tab),
            ),
          ),
      ],
    );
  }

  AppBar _buildAppBar() {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),

            child: Icon(
              Icons.restaurant_menu_rounded,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          const Text('Meals'),
        ],
      ),

      actions: [
        IconButton(
          tooltip: 'Search recipes (${HomeKeyboardShortcuts.searchHint})',

          onPressed: _openSearch,

          icon: const Icon(Icons.search_rounded),
        ),

        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
