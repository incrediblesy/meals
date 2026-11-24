import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_history_repository.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SharedPreferencesAsync preferences;

  static const _storageKey = 'meals.search.history.v1';

  SearchHistoryRepositoryImpl(this.preferences);

  @override
  Future<List<SearchHistoryEntry>> load() async {
    final raw = await preferences.getString(_storageKey);

    if (raw == null) return const [];

    final decoded = jsonDecode(raw);

    if (decoded is! List) {
      throw const FormatException('Invalid search history.');
    }

    final entries = <String, SearchHistoryEntry>{};

    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;

      final query = item['query'];
      final mode = item['mode'];

      if (query is! String || mode is! String || query.trim().length < 2) {
        continue;
      }

      final entry = SearchHistoryEntry(query: query.trim(), mode: mode);

      entries.putIfAbsent(entry.id, () => entry);
    }

    return List.unmodifiable(entries.values.take(20));
  }

  @override
  Future<void> save(List<SearchHistoryEntry> entries) async {
    final data = entries.map((entry) {
      return {'query': entry.query, 'mode': entry.mode};
    }).toList();

    await preferences.setString(_storageKey, jsonEncode(data));
  }
}
