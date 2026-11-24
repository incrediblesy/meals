import '../entities/shopping_item.dart';

abstract interface class ShoppingRepository {
  Future<List<ShoppingItem>> load();

  Future<void> save(List<ShoppingItem> items);
}
