import 'package:material_ui/material_ui.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_network_image.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

class MealItemWidget extends StatelessWidget {
  final MealEntity meal;

  const MealItemWidget({super.key, required this.meal});

  void _openMeal(BuildContext context) {
    Navigator.of(context)
        .pushNamed(AppRouter.mealDetailsRoute, arguments: meal.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => _openMeal(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppNetworkImage(
                url: meal.thumbnail,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: meal.name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (meal.category != null || meal.area != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        if (meal.category != null) meal.category!,
                        if (meal.area != null) meal.area!,
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
