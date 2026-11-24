import 'package:meals/features/meals/domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id, required super.name, super.thumbnail, super.category,
    super.area, super.instructions, super.tags, super.youtube, super.source,
    super.imageSource, super.isFavorite, required super.ingredients, required super.measures,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      MealModel.fromEntity(MealEntity.fromJson(json));

  factory MealModel.fromEntity(MealEntity entity) => MealModel(
    id: entity.id, name: entity.name, thumbnail: entity.thumbnail,
    category: entity.category, area: entity.area, instructions: entity.instructions,
    tags: entity.tags, youtube: entity.youtube, source: entity.source,
    imageSource: entity.imageSource, isFavorite: entity.isFavorite,
    ingredients: entity.ingredients, measures: entity.measures,
  );
}
