import 'package:equatable/equatable.dart';

class MealEntity extends Equatable {
  final String id;
  final String name;
  final String? thumbnail;
  final String? category;
  final String? area;
  final String? instructions;
  final String? tags;
  final String? youtube;
  final String? source;
  final String? imageSource;
  final bool? isFavorite;
  final List<String> ingredients;
  final List<String> measures;

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
