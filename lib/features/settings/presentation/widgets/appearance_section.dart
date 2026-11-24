import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/settings/domain/repositories/settings_repository.dart';

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'settings_section_header.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(
          title: 'Appearance',
          icon: Icons.palette_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final cubit = context.read<SettingsCubit>();
            return Card(
              child: Column(
                children: [
                  _ThemeOption(
                    state: state,
                    preference: ThemePreference.system,
                    title: 'System',
                    subtitle: 'Follow your device settings',
                    icon: Icons.settings_brightness_rounded,
                    onSelected: cubit.setTheme,
                  ),
                  const Divider(),
                  _ThemeOption(
                    state: state,
                    preference: ThemePreference.light,
                    title: 'Light',
                    subtitle: 'Always use light appearance',
                    icon: Icons.light_mode_outlined,
                    onSelected: cubit.setTheme,
                  ),
                  const Divider(),
                  _ThemeOption(
                    state: state,
                    preference: ThemePreference.dark,
                    title: 'Dark',
                    subtitle: 'Always use dark appearance',
                    icon: Icons.dark_mode_outlined,
                    onSelected: cubit.setTheme,
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
          },
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final SettingsState state;
  final ThemePreference preference;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<ThemePreference> onSelected;
  const _ThemeOption({
    required this.state,
    required this.preference,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = state.theme == preference;
    return ListTile(
      enabled: state.canModify,
      selected: selected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          icon,
          color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
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
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? colors.primary : colors.outline,
      ),
      onTap: state.canModify ? () => onSelected(preference) : null,
    );
  }
}
