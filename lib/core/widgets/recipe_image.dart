import 'package:material_ui/material_ui.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    Widget fallback() => ColoredBox(
      color: color.surfaceContainerHighest,
      child: Center(child: Icon(Icons.restaurant_menu, color: color.onSurfaceVariant)),
    );
    final value = url?.trim();
    if (value == null || value.isEmpty) return fallback();
    return Image.network(
      value,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, error, stack) => fallback(),
    );
  }
}
