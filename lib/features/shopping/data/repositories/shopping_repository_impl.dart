import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  final SharedPreferencesAsync preferences;

  static const _storageKey = 'meals.shopping.v1';

  ShoppingRepositoryImpl(this.preferences);

  @override
  Future<List<ShoppingItem>> load() async {
    final raw = await preferences.getString(_storageKey);

    if (raw == null) return const [];

    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Invalid shopping list.');
    }

    final items = <ShoppingItem>[];
    final ids = <int>{};

    for (final value in decoded) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid shopping item.');
      }

      final id = value['id'];
      final name = value['name'];
      final quantity = value['quantity'];
      final purchased = value['isPurchased'];

      if (id is! int ||
          id < 1 ||
          !ids.add(id) ||
          name is! String ||
          name.trim().isEmpty ||
          quantity is! String ||
          purchased is! bool) {
        throw const FormatException('Invalid shopping item fields.');
      }

      items.add(
        ShoppingItem(
          id: id,
          name: name,
          quantity: quantity,
          isPurchased: purchased,
        ),
      );
    }

    return List.unmodifiable(items);
  }

  @override
  Future<void> save(List<ShoppingItem> items) async {
    final data = items.map((item) {
      return {
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'isPurchased': item.isPurchased,
      };
    }).toList();

    await preferences.setString(_storageKey, jsonEncode(data));
  }
}
