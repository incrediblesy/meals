import 'package:material_ui/material_ui.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/widgets/app_network_image.dart';
import 'package:meals/features/categories/domain/entities/category_entity.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/pages/meal_list_page.dart';

class CategoryItem extends StatelessWidget {
  final CategoryEntity category;

  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = category.name ?? 'Unknown';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: category.name == null
            ? null
            : () {
                Navigator.of(context).pushNamed(
                  AppRouter.mealListRoute,
                  arguments: MealListPageArguments(
                    event: GetMealsByQuery(
                      Uri(queryParameters: {'c': name}).query,
                    ),
                    title: name,
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: AppNetworkImage(
                  url: category.thumbnail,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  semanticLabel: name,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
