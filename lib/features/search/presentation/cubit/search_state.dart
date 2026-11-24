import 'package:meals/core/errors/failures.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

enum SearchMode { name, category, cuisine, ingredient }

enum SearchStatus { idle, loading, success, empty, failure }

class SearchState {
  final SearchMode mode;
  final SearchStatus status;
  final String query;
  final List<MealEntity> meals;
  final Failure? failure;

  const SearchState({
    this.mode = SearchMode.name,
    this.status = SearchStatus.idle,
    this.query = '',
    this.meals = const [],
    this.failure,
  });
}
