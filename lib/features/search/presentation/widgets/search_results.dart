import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/meals/presentation/widgets/meal_grid.dart';

import '../cubit/search_state.dart';

class SearchResults extends StatelessWidget {
  final SearchState state;
  const SearchResults({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            '${state.meals.length} ${state.meals.length == 1 ? 'recipe' : 'recipes'} found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: MealGrid(
            meals: state.meals,
            scrollKey: PageStorageKey<String>(
              'search-${state.mode.name}-${state.query}',
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
          ),
        ),
      ],
    );
  }
}
