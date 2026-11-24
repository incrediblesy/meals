import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/planner/domain/entities/planned_meal.dart';
import 'package:meals/features/planner/domain/repositories/planner_repository.dart';
import 'package:meals/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:meals/features/planner/presentation/cubit/planner_state.dart';

class FakePlannerRepository implements PlannerRepository {
  List<PlannedMeal> stored = [];

  bool failOnSave = false;
  bool failOnLoad = false;

  @override
  Future<List<PlannedMeal>> load() async {
    if (failOnLoad) {
      throw Exception('Load failed');
    }

    return List.of(stored);
  }

  @override
  Future<void> save(List<PlannedMeal> meals) async {
    if (failOnSave) {
      throw Exception('Save failed');
    }

    stored = List.of(meals);
  }
}

void main() {
  const chicken = MealEntity(
    id: '1',
    name: 'Chicken',
    ingredients: ['Chicken'],
    measures: ['500 g'],
  );

  const pasta = MealEntity(
    id: '2',
    name: 'Pasta',
    ingredients: ['Pasta'],
    measures: ['250 g'],
  );

  final monday = DateTime(2026, 11, 23);

  late FakePlannerRepository repository;
  late PlannerCubit cubit;

  setUp(() async {
    repository = FakePlannerRepository();

    cubit = PlannerCubit(repository: repository);

    await cubit.load();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads an empty meal plan', () {
    expect(cubit.state.status, PlannerStatus.ready);
    expect(cubit.state.meals, isEmpty);
  });

  test('normalizes dates to midnight', () {
    final entry = PlannedMeal(
      date: DateTime(2026, 11, 23, 18, 30),
      slot: MealSlot.dinner,
      meal: chicken,
    );

    expect(entry.date, monday);
  });

  test('calculates Monday as the start of the week', () {
    expect(startOfWeek(DateTime(2026, 11, 26)), monday);
  });

  test('assigns a meal to a slot', () async {
    final success = await cubit.assignMeal(
      date: monday,
      slot: MealSlot.dinner,
      meal: chicken,
    );

    expect(success, isTrue);

    expect(cubit.state.mealFor(monday, MealSlot.dinner)?.meal.id, chicken.id);
  });

  test('prevents accidental replacement', () async {
    await cubit.assignMeal(date: monday, slot: MealSlot.dinner, meal: chicken);

    final success = await cubit.assignMeal(
      date: monday,
      slot: MealSlot.dinner,
      meal: pasta,
    );

    expect(success, isFalse);
    expect(cubit.state.meals.single.meal.id, chicken.id);
  });

  test('replaces an existing meal explicitly', () async {
    await cubit.assignMeal(date: monday, slot: MealSlot.dinner, meal: chicken);

    await cubit.assignMeal(
      date: monday,
      slot: MealSlot.dinner,
      meal: pasta,
      replaceExisting: true,
    );

    expect(cubit.state.meals.length, 1);
    expect(cubit.state.meals.single.meal.id, pasta.id);
  });

  test('supports multiple slots on the same day', () async {
    await cubit.assignMeal(date: monday, slot: MealSlot.lunch, meal: pasta);

    await cubit.assignMeal(date: monday, slot: MealSlot.dinner, meal: chicken);

    expect(cubit.state.meals.length, 2);
  });

  test('returns only meals from the selected week', () async {
    await cubit.assignMeal(date: monday, slot: MealSlot.dinner, meal: chicken);

    await cubit.assignMeal(
      date: addCalendarDays(monday, 7),
      slot: MealSlot.dinner,
      meal: pasta,
    );

    expect(cubit.state.mealsForWeek(monday).length, 1);
  });

  test('removes a meal assignment', () async {
    await cubit.assignMeal(date: monday, slot: MealSlot.dinner, meal: chicken);

    await cubit.removeMeal(cubit.state.meals.single.id);

    expect(cubit.state.meals, isEmpty);
  });

  test('retains previous state when saving fails', () async {
    repository.failOnSave = true;

    final success = await cubit.assignMeal(
      date: monday,
      slot: MealSlot.dinner,
      meal: chicken,
    );

    expect(success, isFalse);
    expect(cubit.state.meals, isEmpty);
    expect(cubit.state.error, isNotNull);
  });

  test('restores stored assignments', () async {
    await cubit.assignMeal(date: monday, slot: MealSlot.dinner, meal: chicken);

    final restored = PlannerCubit(repository: repository);

    try {
      await restored.load();

      expect(restored.state.meals.single.meal.id, chicken.id);
    } finally {
      await restored.close();
    }
  });
}
