import 'package:material_ui/material_ui.dart';

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

  @override
  Widget build(BuildContext context) {
    final source = url?.trim() ?? '';
    final uri = Uri.tryParse(source);

    final isValid =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;

    final Widget image = isValid
        ? Image.network(
            source,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            errorBuilder: (_, _, _) => _placeholder(context),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return _placeholder(context, isLoading: true);
            },
          )
        : _placeholder(context);

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(borderRadius: borderRadius!, child: image);
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
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.image_not_supported_outlined,
                  size: 32,
                  color: colors.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
