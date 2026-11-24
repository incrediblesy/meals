import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/shopping/domain/entities/shopping_item.dart';
import 'package:meals/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:meals/features/shopping/presentation/cubit/shopping_cubit.dart';
import 'package:meals/features/shopping/presentation/cubit/shopping_state.dart';

class FakeShoppingRepository implements ShoppingRepository {
  List<ShoppingItem> stored = [];

  bool failOnSave = false;

  @override
  Future<List<ShoppingItem>> load() async {
    return List.of(stored);
  }

  @override
  Future<void> save(List<ShoppingItem> items) async {
    if (failOnSave) {
      throw Exception('Storage unavailable');
    }

    stored = List.of(items);
  }
}

void main() {
  late FakeShoppingRepository repository;
  late ShoppingCubit cubit;

  setUp(() async {
    repository = FakeShoppingRepository();

    cubit = ShoppingCubit(repository: repository);

    await cubit.load();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads initial shopping list', () {
    expect(cubit.state.status, ShoppingStatus.ready);
    expect(cubit.state.items, isEmpty);
  });

  test('adds a manual item', () async {
    final success = await cubit.addItem(name: 'Chicken', quantity: '500 g');

    expect(success, isTrue);
    expect(cubit.state.total, 1);
    expect(repository.stored.single.name, 'Chicken');
  });

  test('rejects empty ingredient names', () async {
    final success = await cubit.addItem(name: '   ');

    expect(success, isFalse);
    expect(cubit.state.items, isEmpty);
  });

  test('prevents identical duplicates', () async {
    await cubit.addItem(name: 'Chicken', quantity: '500 g');

    await cubit.addItem(name: ' chicken ', quantity: '500 g');

    expect(cubit.state.total, 1);
  });

  test('preserves different quantities', () async {
    await cubit.addItem(name: 'Chicken', quantity: '500 g');

    await cubit.addItem(name: 'Chicken', quantity: '1 kg');

    expect(cubit.state.total, 2);
  });

  test('adds ingredients from a recipe', () async {
    const meal = MealEntity(
      id: '1',
      name: 'Chicken Rice',
      ingredients: ['Chicken', 'Rice'],
      measures: ['500 g', '250 g'],
    );

    await cubit.addMeal(meal);

    expect(cubit.state.total, 2);
    expect(cubit.state.items.first.name, 'Chicken');
    expect(cubit.state.items.last.quantity, '250 g');
  });

  test('marks items as purchased', () async {
    await cubit.addItem(name: 'Rice');

    final id = cubit.state.items.single.id;

    await cubit.togglePurchased(id);

    expect(cubit.state.purchasedCount, 1);
    expect(cubit.state.remainingCount, 0);
    expect(cubit.state.progress, 1.0);
  });

  test('re-adding purchased item makes it pending', () async {
    await cubit.addItem(name: 'Rice');

    await cubit.togglePurchased(cubit.state.items.single.id);

    await cubit.addItem(name: 'Rice');

    expect(cubit.state.total, 1);
    expect(cubit.state.purchasedCount, 0);
  });

  test('edits name and quantity', () async {
    await cubit.addItem(name: 'Rice');

    final id = cubit.state.items.single.id;

    await cubit.editItem(id, name: 'Basmati rice', quantity: '1 kg');

    expect(cubit.state.items.single.name, 'Basmati rice');
    expect(cubit.state.items.single.quantity, '1 kg');
  });

  test('removes a shopping item', () async {
    await cubit.addItem(name: 'Rice');

    await cubit.removeItem(cubit.state.items.single.id);

    expect(cubit.state.items, isEmpty);
  });

  test('clears only purchased items', () async {
    await cubit.addItem(name: 'Rice');
    await cubit.addItem(name: 'Chicken');

    await cubit.togglePurchased(cubit.state.items.first.id);

    await cubit.clearPurchased();

    expect(cubit.state.total, 1);
    expect(cubit.state.items.single.name, 'Chicken');
  });

  test('retains previous state on save failure', () async {
    await cubit.addItem(name: 'Rice');

    repository.failOnSave = true;

    final success = await cubit.addItem(name: 'Chicken');

    expect(success, isFalse);
    expect(cubit.state.total, 1);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.isSaving, isFalse);
  });

  test('restores saved items in a new Cubit', () async {
    await cubit.addItem(name: 'Rice');

    final restored = ShoppingCubit(repository: repository);

    try {
      await restored.load();

      expect(restored.state.total, 1);
      expect(restored.state.items.single.name, 'Rice');
    } finally {
      await restored.close();
    }
  });

  test('weekly shopping preserves repeated quantities', () async {
    const meal = MealEntity(
      id: '1',
      name: 'Chicken dinner',
      ingredients: ['Chicken'],
      measures: ['500 g'],
    );

    final success = await cubit.addMeals([meal, meal]);

    expect(success, isTrue);
    expect(cubit.state.total, 1);
    expect(cubit.state.items.single.quantity, '2 × (500 g)');
  });
}
