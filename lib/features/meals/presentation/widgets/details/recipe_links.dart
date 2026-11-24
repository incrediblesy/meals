import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'recipe_section_title.dart';

class RecipeLinks extends StatelessWidget {
  final String? video;
  final String? source;
  const RecipeLinks({super.key, this.video, this.source});

  static Uri? _parseUrl(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return uri;
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Show a message when the platform cannot open the link.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open the link.')));
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = _parseUrl(video);
    final sourceUrl = _parseUrl(source);
    if (videoUrl == null && sourceUrl == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RecipeSectionTitle(
          title: 'More about this recipe',
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: 16),
        if (videoUrl != null)
          FilledButton.icon(
            onPressed: () => _open(context, videoUrl),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('Watch video recipe'),
          ),
        if (videoUrl != null && sourceUrl != null) const SizedBox(height: 12),
        if (sourceUrl != null)
          OutlinedButton.icon(
            onPressed: () => _open(context, sourceUrl),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('View original recipe'),
          ),
      ],
    );
  }
}
