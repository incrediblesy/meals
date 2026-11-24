import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/settings/presentation/widgets/cache_settings_section.dart';

import '../widgets/about_section.dart';
import '../widgets/appearance_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ListView(
      key: const PageStorageKey<String>('settings-page'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          'PREFERENCES',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Settings', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Make Meals work the way you like.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const AppearanceSection(),
        const SizedBox(height: AppSpacing.xxl),
        const CacheSettingsSection(),
        const SizedBox(height: AppSpacing.xxl),
        const AboutSection(),
        const SizedBox(height: AppSpacing.xxxl),
        Icon(Icons.restaurant_menu_rounded, size: 32, color: colors.outline),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Meals',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Discover. Cook. Enjoy.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
