import '../entities/planned_meal.dart';

abstract interface class PlannerRepository {
  Future<List<PlannedMeal>> load();

  Future<void> save(List<PlannedMeal> meals);
}
