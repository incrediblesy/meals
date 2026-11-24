import 'package:meals/core/network/network_service.dart';

class SearchFilterCatalog {
  final NetworkService networkService;

  final Map<String, Future<List<String>>> _cache = {};

  SearchFilterCatalog(this.networkService);

  Future<List<String>> load(String key) async {
    final pending = _cache.putIfAbsent(key, () => _fetch(key));

    try {
      return await pending;
    } catch (_) {
      if (identical(_cache[key], pending)) {
        _cache.remove(key);
      }

      rethrow;
    }
  }

  Future<List<String>> _fetch(String key) async {
    final field = switch (key) {
      'c' => 'strCategory',
      'a' => 'strArea',
      'i' => 'strIngredient',
      _ => throw ArgumentError('Invalid filter: $key'),
    };

    final response = await networkService.getRequest(
      '/list.php',
      queryParameters: {key: 'list'},
    );

    final data = response.data;

    if (data is! Map<String, dynamic> || data['meals'] is! List) {
      throw const FormatException('Invalid filter catalog response.');
    }

    final items = data['meals'] as List;

    final values =
        items
            .whereType<Map<String, dynamic>>()
            .map((item) => item[field])
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return List.unmodifiable(values);
  }

  static String normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[\s_]+'), ' ');
  }

  Future<List<String>> suggestions(String key, String query) async {
    final values = await load(key);
    final normalized = normalize(query);

    return values
        .where((value) => normalize(value).contains(normalized))
        .take(12)
        .toList(growable: false);
  }

  Future<String?> resolve(String key, String query) async {
    final values = await load(key);
    final normalized = normalize(query);

    // Prefer an exact match, ignoring capitalization.
    for (final value in values) {
      if (normalize(value) == normalized) {
        return value;
      }
    }

    // Automatically resolve an unambiguous prefix.
    final matches = values
        .where((value) => normalize(value).startsWith(normalized))
        .toList();

    return matches.length == 1 ? matches.first : null;
  }
}
