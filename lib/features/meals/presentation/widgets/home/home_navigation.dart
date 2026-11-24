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

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      selectedIndex: selectedTab.index,
      onDestinationSelected: (index) {
        onChanged(HomeTab.values[index]);
      },
      destinations: HomeTab.values.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.selectedIcon),
          label: tab.label,
        );
      }).toList(),
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
