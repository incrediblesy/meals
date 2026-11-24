import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../../domain/entities/planned_meal.dart';
import '../../domain/repositories/planner_repository.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final SharedPreferencesAsync preferences;

  static const _storageKey = 'meals.planner.v1';

  PlannerRepositoryImpl(this.preferences);

  @override
  Future<List<PlannedMeal>> load() async {
    final raw = await preferences.getString(_storageKey);

    if (raw == null) return const [];

    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Invalid meal plan.');
    }

    final result = <String, PlannedMeal>{};

    for (final value in decoded) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid planned meal.');
      }

      final dateText = value['date'] as String;
      final date = DateTime.parse(dateText);

      if (plannerDateKey(date) != dateText) {
        throw const FormatException('Invalid planned date.');
      }

      final slot = MealSlot.values.byName(value['slot'] as String);

      final data = value['meal'] as Map<String, dynamic>;

      final id = data['id'] as String;
      final name = data['name'] as String;

      if (id.trim().isEmpty || name.trim().isEmpty) {
        throw const FormatException('Invalid recipe.');
      }

      final plannedMeal = PlannedMeal(
        date: date,
        slot: slot,
        meal: MealEntity(
          id: id,
          name: name,
          thumbnail: data['thumbnail'] as String?,
          category: data['category'] as String?,
          area: data['area'] as String?,
          ingredients: List<String>.unmodifiable(data['ingredients'] as List),
          measures: List<String>.unmodifiable(data['measures'] as List),
        ),
      );

      result[plannedMeal.id] = plannedMeal;
    }

    return List.unmodifiable(result.values);
  }

  @override
  Future<void> save(List<PlannedMeal> meals) async {
    final data = meals.map((entry) {
      final meal = entry.meal;

      return {
        'date': plannerDateKey(entry.date),
        'slot': entry.slot.name,
        'meal': {
          'id': meal.id,
          'name': meal.name,
          'thumbnail': meal.thumbnail,
          'category': meal.category,
          'area': meal.area,
          'ingredients': meal.ingredients,
          'measures': meal.measures,
        },
      };
    }).toList();

    await preferences.setString(_storageKey, jsonEncode(data));
  }
}
