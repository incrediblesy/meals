import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meals/core/themes/app_tokens.dart';

import 'settings_section_header.dart';
import 'settings_tile.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});
  static const _apiUrl = 'https://www.themealdb.com/';
  static const _repositoryUrl = 'https://github.com/incrediblesy/Meals';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsSectionHeader(
          title: 'About',
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.restaurant_menu_rounded,
                title: 'About Meals',
                subtitle: 'Your recipe discovery companion',
                onTap: () => _showAbout(context),
              ),
              const Divider(),
              SettingsTile(
                icon: Icons.public_rounded,
                title: 'Recipe data',
                subtitle: 'Powered by TheMealDB',
                external: true,
                onTap: () => _open(context, _apiUrl),
              ),
              const Divider(),
              SettingsTile(
                icon: Icons.code_rounded,
                title: 'Source code',
                subtitle: 'View project on GitHub',
                external: true,
                onTap: () => _open(context, _repositoryUrl),
              ),
              const Divider(),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'Open-source licenses',
                subtitle: 'Third-party libraries',
                onTap: () =>
                    showLicensePage(context: context, applicationName: 'Meals'),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
          'Discover recipes from around the world, save your favorites and find inspiration for your next meal.',
        ),
        SizedBox(height: AppSpacing.lg),
        Text('Built with Flutter, Material UI and TheMealDB API.'),
      ],
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    try {
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Report failure without using a disposed context.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the website.')),
    );
  }
}
