import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';
import 'package:meals/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:meals/features/categories/presentation/widgets/category_item.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesError) {
          return AppError(
            title: 'Unable to load categories',
            message: state.message,
            onRetry: () {
              context.read<CategoriesBloc>().add(FetchCategories());
            },
          );
        }

        if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return const AppEmpty(
              icon: Icons.category_outlined,
              title: 'No categories found',
              message: 'Categories are currently unavailable.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.categories.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              return CategoryItem(category: state.categories[index]);
            },
          );
        }

        return const AppLoading(message: 'Loading categories...');
      },
    );
  }
}
