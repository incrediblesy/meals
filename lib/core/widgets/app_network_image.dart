import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../cache/recipe_image_cache.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  bool get _isValidUrl {
    final uri = Uri.tryParse(url?.trim() ?? '');

    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final fadeDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);

    Widget image;

    if (!_isValidUrl) {
      image = _placeholder(context);
    } else {
      final imageUrl = url!.trim();

      if (kIsWeb) {
        image = Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,

          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return _placeholder(context, isLoading: true);
          },

          errorBuilder: (context, error, stackTrace) {
            return _placeholder(context);
          },
        );
      } else {
        image = CachedNetworkImage(
          imageUrl: imageUrl,
          cacheManager: RecipeImageCache.manager,
          width: width,
          height: height,
          fit: fit,

          fadeInDuration: fadeDuration,
          fadeOutDuration: fadeDuration,

          placeholder: (context, url) {
            return _placeholder(context, isLoading: true);
          },

          errorWidget: (context, url, error) {
            return _placeholder(context);
          },
        );
      }
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return Semantics(image: true, label: semanticLabel, child: image);
  }

  Widget _placeholder(BuildContext context, {bool isLoading = false}) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                )
              : Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.onSurfaceVariant,
                  size: 32,
                ),
        ),
      ),
    );
  }
}
