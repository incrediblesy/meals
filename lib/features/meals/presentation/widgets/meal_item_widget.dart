import 'package:material_ui/material_ui.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/widgets/recipe_image.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

class MealItemWidget extends StatelessWidget {
  final MealEntity meal;
  const MealItemWidget({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRouter.mealDetailsRoute, arguments: meal.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: meal.id,
                child: RecipeImage(url: meal.thumbnail),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
