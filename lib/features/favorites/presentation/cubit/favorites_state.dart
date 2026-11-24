import 'package:equatable/equatable.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

enum FavoritesStatus { initial, loading, ready, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<MealEntity> meals;
  final bool isSaving;
  final String? error;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.meals = const [],
    this.isSaving = false,
    this.error,
  });

  bool contains(String id) {
    return meals.any((meal) => meal.id == id);
  }

  int get count => meals.length;

  bool get canModify => status == FavoritesStatus.ready && !isSaving;

  @override
  List<Object?> get props => [status, meals, isSaving, error];
}
