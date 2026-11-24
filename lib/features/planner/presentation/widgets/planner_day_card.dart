import 'package:material_ui/material_ui.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_network_image.dart';

import '../../domain/entities/planned_meal.dart';

class PlannerDayCard extends StatelessWidget {
  final DateTime date;
  final List<PlannedMeal> meals;
  final bool enabled;
  final ValueChanged<PlannedMeal> onOpen;
  final ValueChanged<PlannedMeal> onRemove;

  const PlannerDayCard({
    super.key,
    required this.date,
    required this.meals,
    required this.enabled,
    required this.onOpen,
    required this.onRemove,
  });

  PlannedMeal? _mealFor(MealSlot slot) {
    for (final meal in meals) {
      if (meal.slot == slot) return meal;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isToday = date == dateOnly(DateTime.now());

    return Card(
      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: isToday ? colors.primary : colors.outlineVariant,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: isToday
                ? colors.primaryContainer
                : colors.surfaceContainerLow,

            padding: const EdgeInsets.all(AppSpacing.lg),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    MaterialLocalizations.of(context).formatMediumDate(date),

                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                    ),
                  ),
                ),

                if (isToday)
                  Text(
                    'Today',
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
              ],
            ),
          ),

          for (final slot in MealSlot.values) ...[
            _buildSlot(context, slot, _mealFor(slot)),

            if (slot != MealSlot.dinner) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSlot(BuildContext context, MealSlot slot, PlannedMeal? entry) {
    final colors = Theme.of(context).colorScheme;

    final icon = switch (slot) {
      MealSlot.breakfast => Icons.free_breakfast_outlined,
      MealSlot.lunch => Icons.lunch_dining_outlined,
      MealSlot.dinner => Icons.dinner_dining_outlined,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),

      leading: entry == null
          ? SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: colors.onSurfaceVariant),
            )
          : AppNetworkImage(
              url: entry.meal.thumbnail,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),

      title: Text(slot.label, style: Theme.of(context).textTheme.labelLarge),

      subtitle: Text(
        entry?.meal.name ?? 'Not planned',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      onTap: entry == null ? null : () => onOpen(entry),

      trailing: entry == null
          ? null
          : IconButton(
              tooltip: 'Remove ${slot.label.toLowerCase()}',
              onPressed: enabled ? () => onRemove(entry) : null,
              icon: const Icon(Icons.close_rounded),
            ),
    );
  }
}
