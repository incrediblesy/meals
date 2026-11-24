import 'package:meals/features/meals/domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.name,
    super.thumbnail,
    super.category,
    super.area,
    super.instructions,
    super.tags,
    super.youtube,
    super.source,
    super.imageSource,
    super.isFavorite,
    required super.ingredients,
    required super.measures,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    for (var i = 1; i <= 20; i++) {
      final ingredient = _readString(json['strIngredient$i']);

      if (ingredient == null) {
        continue;
      }

      ingredients.add(ingredient);
      measures.add(_readString(json['strMeasure$i']) ?? '');
    }

    final id = _readString(json['idMeal']);
    final name = _readString(json['strMeal']);

    if (id == null || name == null) {
      throw const FormatException('Meal ID and name are required.');
    }

    return MealModel(
      id: id,
      name: name,
      thumbnail: _readString(json['strMealThumb']),
      category: _readString(json['strCategory']),
      area: _readString(json['strArea']),
      instructions: _readString(json['strInstructions']),
      tags: _readString(json['strTags']),
      youtube: _readString(json['strYoutube']),
      source: _readString(json['strSource']),
      imageSource: _readString(json['strImageSource']),
      isFavorite: json['isFavorite'] == true,
      ingredients: List.unmodifiable(ingredients),
      measures: List.unmodifiable(measures),
    );
  }

  factory MealModel.fromEntity(MealEntity entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      thumbnail: entity.thumbnail,
      category: entity.category,
      area: entity.area,
      instructions: entity.instructions,
      tags: entity.tags,
      youtube: entity.youtube,
      source: entity.source,
      imageSource: entity.imageSource,
      isFavorite: entity.isFavorite,
      ingredients: List.unmodifiable(entity.ingredients),
      measures: List.unmodifiable(entity.measures),
    );
  }

  static String? _readString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }
}
