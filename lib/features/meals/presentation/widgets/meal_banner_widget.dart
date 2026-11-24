import 'package:material_ui/material_ui.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_network_image.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

class MealBannerWidget extends StatelessWidget {
  final MealEntity meal;

  const MealBannerWidget({super.key, required this.meal});

  void _openRecipe(BuildContext context) {
    Navigator.of(context)
        .pushNamed(AppRouter.mealDetailsRoute, arguments: meal.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.tablet;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: SizedBox(
            width: double.infinity,
            height: isWide ? 360 : 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  url: meal.thumbnail,
                  fit: BoxFit.cover,
                  semanticLabel: meal.name,
                ),

                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black26,
                        Colors.transparent,
                        Color(0xD9000000),
                        Colors.black87,
                      ],
                      stops: [0, 0.2, 0.75, 1],
                    ),
                  ),
                ),

                Positioned(
                  top: AppSpacing.xl,
                  left: AppSpacing.xl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'FEATURED RECIPE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (meal.category != null || meal.area != null) ...[
                        Text(
                          [
                            if (meal.category != null) meal.category!,
                            if (meal.area != null) meal.area!,
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      Text(
                        meal.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWide ? 36 : 26,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Discover the full recipe',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openRecipe(context),
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
