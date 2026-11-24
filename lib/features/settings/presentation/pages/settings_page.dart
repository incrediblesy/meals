import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/settings/domain/repositories/settings_repository.dart';

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return ListView(
          key: const PageStorageKey<String>('settings-page'),
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _buildHeader(context),

            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              context,
              title: 'Appearance',
              icon: Icons.palette_outlined,
            ),

            const SizedBox(height: AppSpacing.md),

            _buildAppearance(context, state),

            const SizedBox(height: AppSpacing.xxl),

            _buildSectionHeader(
              context,
              title: 'About',
              icon: Icons.info_outline_rounded,
            ),

            const SizedBox(height: AppSpacing.md),

            _buildAbout(context),

            const SizedBox(height: AppSpacing.xxxl),

            _buildFooter(context),
          ],
        );
      },
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERENCES',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ================= APPEARANCE =================

  Widget _buildAppearance(BuildContext context, SettingsState state) {
    final cubit = context.read<SettingsCubit>();

    return Card(
      child: Column(
        children: [
          _buildThemeOption(
            context,
            state: state,
            preference: ThemePreference.system,
            title: 'System',
            subtitle: 'Follow your device settings',
            icon: Icons.settings_brightness_rounded,
          ),

          const Divider(),

          _buildThemeOption(
            context,
            state: state,
            preference: ThemePreference.light,
            title: 'Light',
            subtitle: 'Always use light appearance',
            icon: Icons.light_mode_outlined,
          ),

          const Divider(),

          _buildThemeOption(
            context,
            state: state,
            preference: ThemePreference.dark,
            title: 'Dark',
            subtitle: 'Always use dark appearance',
            icon: Icons.dark_mode_outlined,
          ),

          if (state.isSaving || state.status == SettingsStatus.loading)
            const LinearProgressIndicator(minHeight: 2),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),

                  if (state.status == SettingsStatus.failure) ...[
                    const SizedBox(height: AppSpacing.sm),

                    OutlinedButton.icon(
                      onPressed: cubit.load,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required SettingsState state,
    required ThemePreference preference,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isSelected = state.theme == preference;

    return ListTile(
      enabled: state.canModify,
      selected: isSelected,

      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.45),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),

      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
        ),
      ),

      title: Text(title, style: theme.textTheme.titleMedium),

      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),

      trailing: Icon(
        isSelected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: isSelected ? colors.primary : colors.outline,
      ),

      onTap: state.canModify
          ? () {
              context.read<SettingsCubit>().setTheme(preference);
            }
          : null,
    );
  }

  // ================= ABOUT =================

  Widget _buildAbout(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.restaurant_menu_rounded,
            title: 'About Meals',
            subtitle: 'Your recipe discovery companion',
            onTap: () => _showAbout(context),
          ),

          const Divider(),

          _buildSettingsTile(
            context,
            icon: Icons.public_rounded,
            title: 'Recipe data',
            subtitle: 'Powered by TheMealDB',
            onTap: () => _openWebsite(context),
          ),
          const Divider(),

          _buildSettingsTile(
            context,
            icon: Icons.code_rounded,
            title: 'Source code',
            subtitle: 'View project on GitHub',
            onTap: () => _openWebsite(
              context,
              url: 'https://github.com/incrediblesy/meals',
            ),
          ),

          const Divider(),

          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Open-source licenses',
            subtitle: 'Third-party libraries',
            onTap: () {
              showLicensePage(context: context, applicationName: 'Meals');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),

      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: colors.onSurfaceVariant),
      ),

      title: Text(title, style: theme.textTheme.titleMedium),

      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),

      trailing: const Icon(Icons.chevron_right_rounded),

      onTap: onTap,
    );
  }

  // ================= ABOUT DIALOG =================

  void _showAbout(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showAboutDialog(
      context: context,
      applicationName: 'Meals',

      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 32,
          color: colors.onPrimaryContainer,
        ),
      ),

      children: const [
        Text(
          'Discover recipes from around the world, '
          'save your favorites and find inspiration '
          'for your next meal.',
        ),

        SizedBox(height: AppSpacing.lg),

        Text(
          'Built with Flutter, Material UI '
          'and TheMealDB API.',
        ),
      ],
    );
  }

  Future<void> _openWebsite(
    BuildContext context, {
    String url = 'https://www.themealdb.com/',
  }) async {
    final uri = Uri.parse(url);

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (opened || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the website.')),
    );
  }

  // ================= SHARED =================

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),

        const SizedBox(width: AppSpacing.md),

        Text(title, style: theme.textTheme.titleLarge),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.restaurant_menu_rounded,
          size: 32,
          color: theme.colorScheme.outline,
        ),

        const SizedBox(height: AppSpacing.sm),

        Text('Meals', style: theme.textTheme.titleMedium),

        const SizedBox(height: AppSpacing.xs),

        Text(
          'Discover. Cook. Enjoy.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
