import 'package:bloc/bloc.dart';
import 'package:meals/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesCubit({required this.repository}) : super(const FavoritesState());

  // ================= LOAD =================

  Future<void> load() async {
    if (isClosed ||
        state.status == FavoritesStatus.loading ||
        state.status == FavoritesStatus.ready) {
      return;
    }

    emit(const FavoritesState(status: FavoritesStatus.loading));

    try {
      final meals = await repository.load();

      if (isClosed) return;

      emit(
        FavoritesState(
          status: FavoritesStatus.ready,
          meals: List.unmodifiable(meals),
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        const FavoritesState(
          status: FavoritesStatus.failure,
          error: 'Unable to load saved recipes.',
        ),
      );
    }
  }

  // ================= TOGGLE =================

  Future<bool> toggle(MealEntity meal) async {
    if (isClosed || !state.canModify) {
      return false;
    }

    final updated = List<MealEntity>.of(state.meals);

    if (state.contains(meal.id)) {
      updated.removeWhere((item) => item.id == meal.id);
    } else {
      updated.insert(0, meal);
    }

    return _persist(updated);
  }

  // ================= REMOVE =================

  Future<bool> remove(String id) async {
    if (isClosed || !state.canModify) {
      return false;
    }

    if (!state.contains(id)) {
      return true;
    }

    final updated = state.meals.where((meal) => meal.id != id).toList();

    return _persist(updated);
  }

  // ================= SAVE =================

  Future<bool> _persist(List<MealEntity> updated) async {
    final previous = state.meals;

    emit(
      FavoritesState(
        status: FavoritesStatus.ready,
        meals: previous,
        isSaving: true,
      ),
    );

    try {
      await repository.save(updated);

      if (isClosed) return true;

      emit(
        FavoritesState(
          status: FavoritesStatus.ready,
          meals: List.unmodifiable(updated),
        ),
      );

      return true;
    } catch (_) {
      if (isClosed) return false;

      emit(
        FavoritesState(
          status: FavoritesStatus.ready,
          meals: previous,
          error: 'Unable to save changes.',
        ),
      );

      return false;
    }
  }
}
