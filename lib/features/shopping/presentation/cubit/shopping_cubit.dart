import 'package:bloc/bloc.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';
import 'shopping_state.dart';

class ShoppingCubit extends Cubit<ShoppingState> {
  final ShoppingRepository repository;

  ShoppingCubit({required this.repository}) : super(const ShoppingState());

  Future<void> load() async {
    if (isClosed ||
        state.status == ShoppingStatus.loading ||
        state.status == ShoppingStatus.ready) {
      return;
    }

    emit(const ShoppingState(status: ShoppingStatus.loading));

    try {
      final items = await repository.load();

      if (isClosed) return;

      emit(
        ShoppingState(
          status: ShoppingStatus.ready,
          items: List.unmodifiable(items),
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        const ShoppingState(
          status: ShoppingStatus.failure,
          error: 'Unable to load the shopping list.',
        ),
      );
    }
  }

  // ================= ADD ITEM =================

  Future<bool> addItem({required String name, String quantity = ''}) async {
    if (isClosed || !state.canModify) return false;

    name = name.trim();
    quantity = quantity.trim();

    if (name.isEmpty) return false;

    final updated = List<ShoppingItem>.of(state.items);

    _appendItem(updated, name: name, quantity: quantity);

    return _persist(updated);
  }

  // ================= ADD RECIPE =================

  Future<bool> addMeal(MealEntity meal) async {
    if (isClosed || !state.canModify) return false;

    final updated = List<ShoppingItem>.of(state.items);

    for (var i = 0; i < meal.ingredients.length; i++) {
      final ingredient = meal.ingredients[i].trim();

      if (ingredient.isEmpty) continue;

      final quantity = i < meal.measures.length ? meal.measures[i].trim() : '';

      _appendItem(updated, name: ingredient, quantity: quantity);
    }

    return _persist(updated);
  }

  void _appendItem(
    List<ShoppingItem> items, {
    required String name,
    required String quantity,
  }) {
    final existingIndex = items.indexWhere(
      (item) =>
          _normalize(item.name) == _normalize(name) &&
          _normalize(item.quantity) == _normalize(quantity),
    );

    if (existingIndex != -1) {
      final existing = items[existingIndex];

      // If the ingredient was previously purchased,
      // return it to the pending list.
      if (existing.isPurchased) {
        items[existingIndex] = existing.copyWith(isPurchased: false);
      }

      return;
    }

    items.add(ShoppingItem(id: _nextId(items), name: name, quantity: quantity));
  }

  // ================= EDIT =================

  Future<bool> editItem(
    int id, {
    required String name,
    required String quantity,
  }) async {
    if (isClosed || !state.canModify) return false;

    name = name.trim();
    quantity = quantity.trim();

    if (name.isEmpty) return false;

    final updated = List<ShoppingItem>.of(state.items);

    final index = updated.indexWhere((item) => item.id == id);

    if (index == -1) return false;

    final duplicate = updated.any(
      (item) =>
          item.id != id &&
          _normalize(item.name) == _normalize(name) &&
          _normalize(item.quantity) == _normalize(quantity),
    );

    if (duplicate) {
      emit(
        ShoppingState(
          status: ShoppingStatus.ready,
          items: state.items,
          error: 'An identical shopping item already exists.',
        ),
      );

      return false;
    }

    updated[index] = updated[index].copyWith(name: name, quantity: quantity);

    return _persist(updated);
  }

  // ================= PURCHASE STATUS =================

  Future<bool> togglePurchased(int id) async {
    if (isClosed || !state.canModify) return false;

    final updated = List<ShoppingItem>.of(state.items);

    final index = updated.indexWhere((item) => item.id == id);

    if (index == -1) return false;

    final item = updated[index];

    updated[index] = item.copyWith(isPurchased: !item.isPurchased);

    return _persist(updated);
  }

  // ================= REMOVE =================

  Future<bool> removeItem(int id) async {
    if (isClosed || !state.canModify) return false;

    return _persist(state.items.where((item) => item.id != id).toList());
  }

  Future<bool> clearPurchased() async {
    if (isClosed || !state.canModify) return false;

    return _persist(state.items.where((item) => !item.isPurchased).toList());
  }

  // ================= PERSISTENCE =================

  Future<bool> _persist(List<ShoppingItem> updated) async {
    final previous = state.items;

    emit(
      ShoppingState(
        status: ShoppingStatus.ready,
        items: previous,
        isSaving: true,
      ),
    );

    try {
      await repository.save(updated);

      if (isClosed) return true;

      emit(
        ShoppingState(
          status: ShoppingStatus.ready,
          items: List.unmodifiable(updated),
        ),
      );

      return true;
    } catch (_) {
      if (isClosed) return false;

      emit(
        ShoppingState(
          status: ShoppingStatus.ready,
          items: previous,
          error: 'Unable to save shopping list changes.',
        ),
      );

      return false;
    }
  }

  // ================= HELPERS =================

  int _nextId(List<ShoppingItem> items) {
    return items.fold<int>(
          0,
          (maximum, item) => item.id > maximum ? item.id : maximum,
        ) +
        1;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<bool> addMeals(Iterable<MealEntity> meals) async {
    if (isClosed || !state.canModify) return false;

    final groups =
        <(String, String), ({String name, String quantity, int count})>{};

    for (final meal in meals) {
      for (var i = 0; i < meal.ingredients.length; i++) {
        final name = meal.ingredients[i].trim();

        if (name.isEmpty) continue;

        final quantity = i < meal.measures.length
            ? meal.measures[i].trim()
            : '';

        final key = (_normalize(name), _normalize(quantity));

        final previous = groups[key];

        groups[key] = (
          name: previous?.name ?? name,
          quantity: previous?.quantity ?? quantity,
          count: (previous?.count ?? 0) + 1,
        );
      }
    }

    if (groups.isEmpty) return false;

    final updated = List<ShoppingItem>.of(state.items);

    for (final group in groups.values) {
      final quantity = group.count == 1
          ? group.quantity
          : group.quantity.isEmpty
          ? '${group.count} recipe uses'
          : '${group.count} × (${group.quantity})';

      _appendItem(updated, name: group.name, quantity: quantity);
    }

    return _persist(updated);
  }
}
