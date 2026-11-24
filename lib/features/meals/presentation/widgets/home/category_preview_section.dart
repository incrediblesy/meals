import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';
import 'package:meals/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:meals/features/categories/presentation/widgets/category_item.dart';

class CategoryPreviewSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const CategoryPreviewSection({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore categories', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Find recipes by food category',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View all')),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesError) {
              return Card(
                child: AppError(
                  title: 'Categories unavailable',
                  message: state.message,
                  onRetry: () {
                    context.read<CategoriesBloc>().add(FetchCategories());
                  },
                ),
              );
            }

            if (state is CategoriesLoaded) {
              if (state.categories.isEmpty) {
                return const Card(
                  child: AppEmpty(
                    icon: Icons.category_outlined,
                    title: 'No categories found',
                  ),
                );
              }

              return _buildGrid(state);
            }

            return const Card(
              child: SizedBox(
                height: 160,
                child: AppLoading(message: 'Loading categories...'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGrid(CategoriesLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          >= 900 => 4,
          >= 500 => 3,
          _ => 2,
        };

        final categories = state.categories
            .take(columns == 4 ? 8 : 6)
            .toList(growable: false);

        return GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 150,
          ),
          itemBuilder: (context, index) {
            return CategoryItem(category: categories[index]);
          },
        );
      },
    );
  }
}
