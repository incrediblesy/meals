import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class RecipeCacheStore {
  Future<String?> read();

  Future<void> write(String value);

  Future<void> clear();
}

class PreferencesRecipeCacheStore implements RecipeCacheStore {
  final SharedPreferencesAsync preferences;

  static const _key = 'meals.recipe.cache.v1';

  PreferencesRecipeCacheStore(this.preferences);

  @override
  Future<String?> read() {
    return preferences.getString(_key);
  }

  @override
  Future<void> write(String value) {
    return preferences.setString(_key, value);
  }

  @override
  Future<void> clear() {
    return preferences.remove(_key);
  }
}

class RecipeCache extends ChangeNotifier {
  final RecipeCacheStore store;

  static const int maxEntries = 100;

  Future<void> _pending = Future<void>.value();

  int? _count;

  int? get count => _count;

  RecipeCache(SharedPreferencesAsync preferences)
    : store = PreferencesRecipeCacheStore(preferences);

  RecipeCache.withStore(this.store);

  // Serialize reads and writes to prevent lost updates.
  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());

    _pending = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return result;
  }

  Future<Map<String, dynamic>> _load() async {
    final raw = await store.read();

    if (raw == null) return {};

    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid recipe cache.');
    }

    return decoded;
  }

  void _updateCount(int value) {
    if (_count == value) return;

    _count = value;
    notifyListeners();
  }

  // ================= READ =================

  Future<Map<String, dynamic>?> read(String id) {
    return _enqueue(() async {
      final entries = await _load();

      _updateCount(entries.length);

      final data = entries[id];

      if (!_isValid(id, data)) {
        return null;
      }

      return data as Map<String, dynamic>;
    });
  }

  // ================= WRITE =================

  Future<void> write(String id, Object? data) {
    return _enqueue(() async {
      if (!_isValid(id, data)) return;

      final entries = await _load();

      // Move updated entries to the end.
      entries.remove(id);
      entries[id] = data;

      while (entries.length > maxEntries) {
        entries.remove(entries.keys.first);
      }

      await store.write(jsonEncode(entries));

      _updateCount(entries.length);
    });
  }

  // ================= VALIDATION =================

  bool _isValid(String id, Object? data) {
    if (data is! Map<String, dynamic>) {
      return false;
    }

    final meals = data['meals'];

    if (meals is! List || meals.length != 1) {
      return false;
    }

    final meal = meals.first;

    if (meal is! Map<String, dynamic>) {
      return false;
    }

    final name = meal['strMeal'];

    return meal['idMeal'] == id && name is String && name.trim().isNotEmpty;
  }

  // ================= MANAGEMENT =================

  Future<void> refreshCount() {
    return _enqueue(() async {
      final entries = await _load();

      _updateCount(entries.length);
    });
  }

  Future<void> clear() {
    return _enqueue(() async {
      await store.clear();

      _updateCount(0);
    });
  }
}
