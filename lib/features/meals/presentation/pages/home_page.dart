import 'package:material_ui/material_ui.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/categories/presentation/pages/categories_page.dart';
import 'package:meals/features/favorites/presentation/pages/favorites_page.dart';
import 'package:meals/features/settings/presentation/pages/settings_page.dart';

import '../widgets/home/home_navigation.dart';
import 'discover_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeTab _selectedTab = HomeTab.discover;

  void _selectTab(HomeTab tab) {
    if (_selectedTab == tab) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _selectedTab = tab;
    });
  }

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
                  HomeSidebar(selectedTab: _selectedTab, onChanged: _selectTab),

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
    );
  }

  Widget _buildPages() {
    return IndexedStack(
      index: _selectedTab.index,
      sizing: StackFit.expand,
      children: [
        DiscoverPage(
          isActive: _selectedTab == HomeTab.discover,
          onViewCategories: () {
            _selectTab(HomeTab.categories);
          },
        ),

        const CategoriesPage(),

        FavoritesPage(
          onDiscover: () {
            _selectTab(HomeTab.discover);
          },
        ),

        const SettingsPage(),
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
    );
  }
}
