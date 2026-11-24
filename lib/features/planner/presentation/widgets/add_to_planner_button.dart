import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import 'plan_meal_dialog.dart';

class AddToPlannerButton extends StatelessWidget {
  final MealEntity meal;

  const AddToPlannerButton({super.key, required this.meal});

  Future<void> _openPlanner(BuildContext context) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PlanMealDialog(meal: meal),
    );

    if (!context.mounted || saved != true) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      const SnackBar(content: Text('Recipe added to your meal plan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,

          child: OutlinedButton.icon(
            onPressed: state.canModify ? () => _openPlanner(context) : null,

            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Add to meal plan'),
          ),
        );
      },
    );
  }
}
