import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';

enum HomeTab {
  discover('Discover', Icons.explore_outlined, Icons.explore_rounded),
  categories('Categories', Icons.grid_view_outlined, Icons.grid_view_rounded),
  favorites('Favorites', Icons.favorite_border_rounded, Icons.favorite_rounded),
  shopping(
    'Shopping',
    Icons.shopping_cart_outlined,
    Icons.shopping_cart_rounded,
  ),
  planner(
    'Planner',
    Icons.calendar_month_outlined,
    Icons.calendar_month_rounded,
  ),
  settings('Settings', Icons.settings_outlined, Icons.settings_rounded);

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const HomeTab(this.label, this.icon, this.selectedIcon);
}

// ================= MOBILE NAVIGATION =================

class HomeNavigationBar extends StatelessWidget {
  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onChanged;

  const HomeNavigationBar({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  static const _primaryTabs = [
    HomeTab.discover,
    HomeTab.categories,
    HomeTab.favorites,
  ];

  static const _secondaryTabs = [
    HomeTab.shopping,
    HomeTab.planner,
    HomeTab.settings,
  ];

  NavigationDestination _destination(HomeTab tab) {
    return NavigationDestination(
      icon: Icon(tab.icon),
      selectedIcon: Icon(tab.selectedIcon),
      label: tab.label,
    );
  }

  Future<void> _showMore(BuildContext context) async {
    final result = await showModalBottomSheet<HomeTab>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('More', style: theme.textTheme.headlineSmall),
                ),

                for (final tab in _secondaryTabs)
                  ListTile(
                    selected: selectedTab == tab,
                    selectedTileColor: colors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    leading: Icon(
                      selectedTab == tab ? tab.selectedIcon : tab.icon,
                    ),
                    title: Text(tab.label),
                    trailing: selectedTab == tab
                        ? Icon(Icons.check_rounded, color: colors.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(tab),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || result == null) return;

    onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        if (!compact) {
          return NavigationBar(
            selectedIndex: selectedTab.index,
            onDestinationSelected: (index) {
              onChanged(HomeTab.values[index]);
            },
            destinations: HomeTab.values.map(_destination).toList(),
          );
        }

        final index = _primaryTabs.indexOf(selectedTab);

        return NavigationBar(
          selectedIndex: index == -1 ? _primaryTabs.length : index,

          labelBehavior: constraints.maxWidth < 360
              ? NavigationDestinationLabelBehavior.onlyShowSelected
              : NavigationDestinationLabelBehavior.alwaysShow,

          onDestinationSelected: (index) {
            if (index == _primaryTabs.length) {
              _showMore(context);
              return;
            }

            onChanged(_primaryTabs[index]);
          },

          destinations: [
            ..._primaryTabs.map(_destination),

            const NavigationDestination(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'More',
            ),
          ],
        );
      },
    );
  }
}

// ================= DESKTOP SIDEBAR =================

class HomeSidebar extends StatelessWidget {
  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onChanged;

  const HomeSidebar({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  static const double width = 224;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      child: ColoredBox(
        color: colors.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  key: const PageStorageKey<String>('desktop-sidebar'),
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'WORKSPACE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    ...HomeTab.values.map(
                      (tab) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _NavigationItem(
                          tab: tab,
                          isSelected: selectedTab == tab,
                          onTap: () => onChanged(tab),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
            ],
          ),
        ),
      ),
    );
  }
}

// ================= NAVIGATION ITEM =================

class _NavigationItem extends StatelessWidget {
  final HomeTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final foreground = isSelected
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;

    final radius = BorderRadius.circular(AppRadius.md);

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryContainer : Colors.transparent,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            hoverColor: colors.primary.withValues(alpha: 0.06),
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? tab.selectedIcon : tab.icon,
                      size: 24,
                      color: foreground,
                    ),

                    const SizedBox(width: AppSpacing.md),

                    Expanded(
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),

                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
