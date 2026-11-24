import 'package:equatable/equatable.dart';

import '../../domain/entities/planned_meal.dart';

enum PlannerStatus { initial, loading, ready, failure }

class PlannerState extends Equatable {
  final PlannerStatus status;
  final List<PlannedMeal> meals;
  final bool isSaving;
  final String? error;

  const PlannerState({
    this.status = PlannerStatus.initial,
    this.meals = const [],
    this.isSaving = false,
    this.error,
  });

  bool get canModify => status == PlannerStatus.ready && !isSaving;

  PlannedMeal? mealFor(DateTime date, MealSlot slot) {
    final id = '${plannerDateKey(date)}-${slot.name}';

    for (final meal in meals) {
      if (meal.id == id) return meal;
    }

    return null;
  }

  List<PlannedMeal> mealsForWeek(DateTime date) {
    final start = startOfWeek(date);
    final end = addCalendarDays(start, 7);

    return meals
        .where((meal) {
          return !meal.date.isBefore(start) && meal.date.isBefore(end);
        })
        .toList(growable: false);
  }

  @override
  List<Object?> get props => [status, meals, isSaving, error];
}
