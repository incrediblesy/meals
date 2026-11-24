import 'package:material_ui/material_ui.dart';

import 'package:meals/core/themes/app_tokens.dart';

class MealGridSkeleton extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const MealGridSkeleton({
    super.key,
    this.label = 'Loading recipes',
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final grid = LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding = padding.resolve(Directionality.of(context));

        final available = constraints.maxWidth - resolvedPadding.horizontal;

        final columns = ((available + AppSpacing.lg) / 196)
            .floor()
            .clamp(1, 6)
            .toInt();

        return GridView.builder(
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          itemCount: columns * 3,

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
          ),

          itemBuilder: (context, index) {
            return const _MealSkeletonCard();
          },
        );
      },
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,

      child: ExcludeSemantics(
        child: reduceMotion
            ? grid
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),

                duration: const Duration(milliseconds: 250),

                curve: Curves.easeOut,

                child: grid,

                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
              ),
      ),
    );
  }
}

class _MealSkeletonCard extends StatelessWidget {
  const _MealSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ColoredBox(color: colors.surfaceContainerHighest)),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(context, widthFactor: 0.9, height: 14),

                const SizedBox(height: AppSpacing.sm),

                _line(context, widthFactor: 0.6, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context, {
    required double widthFactor,
    required double height,
  }) {
    return FractionallySizedBox(
      widthFactor: widthFactor,

      child: Container(
        height: height,

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,

          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
