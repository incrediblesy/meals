import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final String id;
  final String name;
  final String? thumbnail,
      category,
      area,
      instructions,
      tags,
      youtube,
      source,
      imageSource;
  final bool? isFavorite;
  final List<String> ingredients, measures;

  const MealEntity({
    required this.id,
    required this.name,
    this.thumbnail,
    this.category,
    this.area,
    this.instructions,
    this.tags,
    this.youtube,
    this.source,
    this.imageSource,
    this.isFavorite,
    required this.ingredients,
    required this.measures,
  });

  factory MealEntity.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      if (ingredient is! String || ingredient.trim().isEmpty) continue;
      final measure = json['strMeasure$i'];
      ingredients.add(ingredient.trim());
      measures.add(measure is String ? measure.trim() : '');
    }
    return MealEntity(
      id: json['idMeal'],
      name: json['strMeal'],
      thumbnail: json['strMealThumb'],
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      tags: json['strTags'],
      youtube: json['strYoutube'],
      source: json['strSource'],
      imageSource: json['strImageSource'],
      isFavorite: json['isFavorite'],
      ingredients: List.unmodifiable(ingredients),
      measures: List.unmodifiable(measures),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    thumbnail,
    category,
    area,
    instructions,
    tags,
    youtube,
    source,
    imageSource,
    isFavorite,
    ingredients,
    measures,
  ];
}
