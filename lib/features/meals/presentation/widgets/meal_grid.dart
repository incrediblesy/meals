import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import 'meal_item_widget.dart';

class MealGrid extends StatelessWidget {
  final List<MealEntity> meals;
  final PageStorageKey<String>? scrollKey;
  final EdgeInsetsGeometry padding;

  const MealGrid({
    super.key,
    required this.meals,
    this.scrollKey,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding = padding.resolve(Directionality.of(context));
        final available = constraints.maxWidth - resolvedPadding.horizontal;
        final columns = ((available + AppSpacing.lg) / 196)
            .floor()
            .clamp(1, 6)
            .toInt();
        return GridView.builder(
          key: scrollKey,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
          ),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return MealItemWidget(key: ValueKey(meal.id), meal: meal);
          },
        );
      },
    );
  }
}
