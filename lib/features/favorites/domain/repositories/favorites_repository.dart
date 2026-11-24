import 'package:meals/features/meals/domain/entities/meal_entity.dart';

abstract interface class FavoritesRepository {
  Future<List<MealEntity>> load();

  Future<void> save(List<MealEntity> meals);
}
