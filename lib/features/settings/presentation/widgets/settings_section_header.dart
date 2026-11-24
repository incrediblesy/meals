import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const SettingsSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
      ],
    );
  }
}
