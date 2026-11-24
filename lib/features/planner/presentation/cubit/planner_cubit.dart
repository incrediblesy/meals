import 'package:bloc/bloc.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../../domain/entities/planned_meal.dart';
import '../../domain/repositories/planner_repository.dart';
import 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  final PlannerRepository repository;

  PlannerCubit({required this.repository}) : super(const PlannerState());

  Future<void> load() async {
    if (isClosed ||
        state.status == PlannerStatus.loading ||
        state.status == PlannerStatus.ready) {
      return;
    }

    emit(const PlannerState(status: PlannerStatus.loading));

    try {
      final meals = await repository.load();

      if (isClosed) return;

      emit(
        PlannerState(
          status: PlannerStatus.ready,
          meals: List.unmodifiable(meals),
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        const PlannerState(
          status: PlannerStatus.failure,
          error: 'Unable to load your meal plan.',
        ),
      );
    }
  }

  Future<bool> assignMeal({
    required DateTime date,
    required MealSlot slot,
    required MealEntity meal,
    bool replaceExisting = false,
  }) async {
    if (isClosed || !state.canModify) return false;

    final existing = state.mealFor(date, slot);

    if (existing != null && !replaceExisting) {
      return false;
    }

    final entry = PlannedMeal(date: date, slot: slot, meal: meal);

    final updated = [
      ...state.meals.where((item) => item.id != entry.id),
      entry,
    ];

    updated.sort((a, b) => a.id.compareTo(b.id));

    return _persist(updated);
  }

  Future<bool> removeMeal(String id) async {
    if (isClosed || !state.canModify) return false;

    return _persist(state.meals.where((meal) => meal.id != id).toList());
  }

  Future<bool> _persist(List<PlannedMeal> updated) async {
    final previous = state.meals;

    emit(
      PlannerState(
        status: PlannerStatus.ready,
        meals: previous,
        isSaving: true,
      ),
    );

    try {
      await repository.save(updated);

      if (isClosed) return true;

      emit(
        PlannerState(
          status: PlannerStatus.ready,
          meals: List.unmodifiable(updated),
        ),
      );

      return true;
    } catch (_) {
      if (isClosed) return false;

      emit(
        PlannerState(
          status: PlannerStatus.ready,
          meals: previous,
          error: 'Unable to save meal plan changes.',
        ),
      );

      return false;
    }
  }
}
