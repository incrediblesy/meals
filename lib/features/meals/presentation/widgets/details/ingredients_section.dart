import 'package:material_ui/material_ui.dart';

import '../../../domain/entities/meal_entity.dart';
import 'recipe_section_title.dart';

class IngredientsSection extends StatelessWidget {
  final MealEntity meal;
  final Set<int> checked;
  final ValueChanged<int> onToggle;
  final VoidCallback onReset;

  const IngredientsSection({
    super.key,
    required this.meal,
    required this.checked,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = meal.ingredients.length;
    final count = checked.where((index) => index >= 0 && index < total).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: RecipeSectionTitle(
                title: 'Ingredients',
                icon: Icons.shopping_basket_outlined,
              ),
            ),
            TextButton(
              onPressed: count == 0 ? null : onReset,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (total == 0)
          const Text('Ingredients are unavailable.')
        else ...[
          Text(
            '$count of $total ingredients prepared',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 20),
          for (var index = 0; index < total; index++)
            _IngredientTile(
              ingredient: meal.ingredients[index],
              measure: index < meal.measures.length
                  ? meal.measures[index].trim()
                  : '',
              isChecked: checked.contains(index),
              onToggle: () => onToggle(index),
            ),
        ],
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String ingredient;
  final String measure;
  final bool isChecked;
  final VoidCallback onToggle;
  const _IngredientTile({
    required this.ingredient,
    required this.measure,
    required this.isChecked,
    required this.onToggle,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(14);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isChecked
          ? colors.primaryContainer.withValues(alpha: 0.45)
          : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: CheckboxListTile(
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: radius),
        onChanged: (_) => onToggle(),
        title: Text(
          ingredient,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: isChecked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isChecked ? colors.onSurfaceVariant : colors.onSurface,
          ),
        ),
        subtitle: measure.isEmpty
            ? null
            : Text(measure, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
