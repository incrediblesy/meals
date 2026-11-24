import 'package:material_ui/material_ui.dart';

import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:meals/features/meals/presentation/pages/meal_list_page.dart';

class AlphabetSection extends StatelessWidget {
  const AlphabetSection({super.key});

  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  void _openLetter(BuildContext context, String letter) {
    Navigator.of(context).pushNamed(
      AppRouter.mealListRoute,
      arguments: MealListPageArguments(
        event: ListMealsByFirstLetter(letter),
        title: 'Meals starting with $letter',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        key: const PageStorageKey<String>('alphabet-expansion'),
        leading: Icon(
          Icons.sort_by_alpha_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Browse A–Z'),
        subtitle: const Text('Find recipes by their first letter'),
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _alphabet.split('').map((letter) {
                return ActionChip(
                  label: SizedBox(
                    width: 24,
                    child: Text(letter, textAlign: TextAlign.center),
                  ),
                  onPressed: () => _openLetter(context, letter),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
