import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meals/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/meals/data/models/meal_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final SharedPreferencesAsync preferences;

  static const String _storageKey = 'meals.favorites.v1';

  FavoritesRepositoryImpl(this.preferences);

  @override
  Future<List<MealEntity>> load() async {
    final raw = await preferences.getString(_storageKey);

    if (raw == null) {
      return const [];
    }

    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Invalid favorites data.');
    }

    final meals = <String, MealEntity>{};

    for (final item in decoded) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid favorite recipe.');
      }

      final meal = MealModel.fromJson(item);

      meals[meal.id] = meal;
    }

    return List.unmodifiable(meals.values);
  }

  @override
  Future<void> save(List<MealEntity> meals) async {
    final data = meals.map((meal) {
      return {
        'idMeal': meal.id,
        'strMeal': meal.name,
        'strMealThumb': meal.thumbnail,
        'strCategory': meal.category,
        'strArea': meal.area,
      };
    }).toList();

    await preferences.setString(_storageKey, jsonEncode(data));
  }
}
