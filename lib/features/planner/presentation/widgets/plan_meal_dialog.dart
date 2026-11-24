import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../../domain/entities/planned_meal.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';

class PlanMealDialog extends StatefulWidget {
  final MealEntity meal;

  const PlanMealDialog({super.key, required this.meal});

  @override
  State<PlanMealDialog> createState() => _PlanMealDialogState();
}

class _PlanMealDialogState extends State<PlanMealDialog> {
  DateTime _date = dateOnly(DateTime.now());
  MealSlot _slot = MealSlot.dinner;

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );

    if (!mounted || selected == null) return;

    setState(() {
      _date = dateOnly(selected);
    });
  }

  Future<void> _save(bool replaceExisting) async {
    final success = await context.read<PlannerCubit>().assignMeal(
      date: _date,
      slot: _slot,
      meal: widget.meal,
      replaceExisting: replaceExisting,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        final existing = state.mealFor(_date, _slot);

        return AlertDialog(
          title: const Text('Plan this meal'),
          scrollable: true,

          content: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.meal.name, style: theme.textTheme.titleMedium),

                const SizedBox(height: AppSpacing.lg),

                OutlinedButton.icon(
                  onPressed: state.isSaving ? null : _selectDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    MaterialLocalizations.of(context).formatFullDate(_date),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text('Meal type', style: theme.textTheme.titleSmall),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final slot in MealSlot.values)
                      ChoiceChip(
                        label: Text(slot.label),
                        selected: _slot == slot,
                        onSelected: state.isSaving
                            ? null
                            : (selected) {
                                if (!selected) return;

                                setState(() {
                                  _slot = slot;
                                });
                              },
                      ),
                  ],
                ),

                if (existing != null) ...[
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'This slot already contains '
                    '${existing.meal.name}. '
                    'Saving will replace it.',
                    style: TextStyle(color: theme.colorScheme.tertiary),
                  ),
                ],

                if (state.error != null) ...[
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    state.error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],

                if (state.isSaving) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: state.isSaving
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: state.canModify ? () => _save(existing != null) : null,

              child: Text(existing == null ? 'Add to plan' : 'Replace meal'),
            ),
          ],
        );
      },
    );
  }
}
