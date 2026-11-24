import 'package:material_ui/material_ui.dart';

import 'package:meals/core/cache/recipe_cache.dart';
import 'package:meals/core/cache/recipe_image_cache.dart';
import 'package:meals/core/di/injector.dart';
import 'package:meals/core/themes/app_tokens.dart';

class CacheSettingsSection extends StatefulWidget {
  const CacheSettingsSection({super.key});

  @override
  State<CacheSettingsSection> createState() => _CacheSettingsSectionState();
}

class _CacheSettingsSectionState extends State<CacheSettingsSection> {
  late final RecipeCache _cache;

  bool _isClearing = false;

  @override
  void initState() {
    super.initState();

    _cache = sl<RecipeCache>();

    _refresh();
  }

  Future<void> _refresh() async {
    try {
      await _cache.refreshCount();
    } catch (_) {
      // Cache statistics are optional.
    }
  }

  Future<void> _clearCache() async {
    if (_isClearing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear cached data?'),

          content: const Text(
            'Downloaded recipe details and cached '
            'images will be removed.\n\n'
            'Favorites, shopping lists, meal plans, '
            'search history and settings will remain.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Clear cache'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true || _isClearing) {
      return;
    }

    setState(() {
      _isClearing = true;
    });

    var success = false;

    try {
      await _cache.clear();

      await RecipeImageCache.clear();

      success = true;
    } catch (_) {
      // Report partial or unsuccessful cleanup.
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Cache cleared successfully.'
              : 'Unable to clear all cached data.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.storage_rounded, color: colors.primary),

            const SizedBox(width: AppSpacing.md),

            Text('Storage', style: theme.textTheme.titleLarge),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Card(
          child: Column(
            children: [
              ListenableBuilder(
                listenable: _cache,
                builder: (context, _) {
                  final count = _cache.count;

                  return ListTile(
                    leading: Icon(
                      Icons.offline_pin_outlined,
                      color: colors.primary,
                    ),

                    title: const Text('Offline recipes'),

                    subtitle: Text(
                      count == null
                          ? 'Cache statistics unavailable'
                          : count == 1
                          ? '1 cached recipe'
                          : '$count cached recipes',
                    ),

                    trailing: IconButton(
                      tooltip: 'Refresh cache statistics',
                      onPressed: _isClearing ? null : _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  );
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),

                title: const Text('Clear cache'),

                subtitle: const Text('Remove downloaded recipes and images'),

                trailing: _isClearing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right_rounded),

                onTap: _isClearing ? null : _clearCache,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Previously opened recipes can be available '
          'without an internet connection.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
