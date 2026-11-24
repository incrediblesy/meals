import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:meals/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:meals/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  List<MealEntity> stored = [];

  bool failOnSave = false;

  @override
  Future<List<MealEntity>> load() async {
    return List.of(stored);
  }

  @override
  Future<void> save(List<MealEntity> meals) async {
    if (failOnSave) {
      throw Exception('Storage unavailable');
    }

    stored = List.of(meals);
  }
}

void main() {
  const meal = MealEntity(
    id: '123',
    name: 'Chicken Soup',
    ingredients: [],
    measures: [],
  );

  late FakeFavoritesRepository repository;
  late FavoritesCubit cubit;

  setUp(() {
    repository = FakeFavoritesRepository();

    cubit = FavoritesCubit(repository: repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads existing favorites', () async {
    repository.stored = [meal];

    await cubit.load();

    expect(cubit.state.status, FavoritesStatus.ready);

    expect(cubit.state.contains(meal.id), isTrue);
    expect(cubit.state.count, 1);
  });

  test('adds a favorite', () async {
    await cubit.load();

    final success = await cubit.toggle(meal);

    expect(success, isTrue);
    expect(cubit.state.contains(meal.id), isTrue);
    expect(repository.stored, contains(meal));
  });

  test('toggles an existing favorite off', () async {
    await cubit.load();

    await cubit.toggle(meal);
    await cubit.toggle(meal);

    expect(cubit.state.meals, isEmpty);
    expect(repository.stored, isEmpty);
  });

  test('removes favorite by ID', () async {
    repository.stored = [meal];

    await cubit.load();
    await cubit.remove(meal.id);

    expect(cubit.state.meals, isEmpty);
  });

  test('preserves state when saving fails', () async {
    await cubit.load();

    repository.failOnSave = true;

    final success = await cubit.toggle(meal);

    expect(success, isFalse);
    expect(cubit.state.meals, isEmpty);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.error, isNotNull);
  });

  test('restores favorites in a new Cubit', () async {
    await cubit.load();
    await cubit.toggle(meal);

    final restoredCubit = FavoritesCubit(repository: repository);

    try {
      await restoredCubit.load();

      expect(restoredCubit.state.contains(meal.id), isTrue);
    } finally {
      await restoredCubit.close();
    }
  });
}
