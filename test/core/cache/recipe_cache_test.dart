import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meals/core/cache/recipe_cache.dart';
import 'package:meals/core/network/recipe_cache_interceptor.dart';

class FakeCacheStore implements RecipeCacheStore {
  String? stored;

  bool failOnWrite = false;

  @override
  Future<String?> read() async => stored;

  @override
  Future<void> write(String value) async {
    if (failOnWrite) {
      throw Exception('Storage unavailable');
    }

    stored = value;
  }

  @override
  Future<void> clear() async {
    stored = null;
  }
}

Map<String, dynamic> recipe(String id) {
  return {
    'meals': [
      {
        'idMeal': id,
        'strMeal': 'Chicken Soup',
        'strInstructions': 'Heat water.\nAdd chicken.',
        'strIngredient1': 'Chicken',
        'strMeasure1': '500 g',
      },
    ],
  };
}

class FakeRecipeAdapter implements HttpClientAdapter {
  bool offline = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (offline) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }

    final id = options.uri.queryParameters['i']!;

    return ResponseBody.fromString(
      jsonEncode(recipe(id)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeCacheStore store;
  late RecipeCache cache;

  setUp(() {
    store = FakeCacheStore();
    cache = RecipeCache.withStore(store);
  });

  tearDown(() {
    cache.dispose();
  });

  test('returns null for uncached recipe', () async {
    expect(await cache.read('1'), isNull);
  });

  test('stores complete recipe data', () async {
    await cache.write('1', recipe('1'));

    expect(await cache.read('1'), recipe('1'));

    expect(cache.count, 1);
  });

  test('rejects invalid recipe responses', () async {
    await cache.write('1', {'meals': null});

    expect(await cache.read('1'), isNull);
  });

  test('rejects mismatched recipe IDs', () async {
    await cache.write('1', recipe('2'));

    expect(await cache.read('1'), isNull);
  });

  test('serializes concurrent writes', () async {
    await Future.wait([
      cache.write('1', recipe('1')),
      cache.write('2', recipe('2')),
      cache.write('3', recipe('3')),
    ]);

    expect(cache.count, 3);
  });

  test('enforces maximum cache size', () async {
    for (var i = 0; i <= RecipeCache.maxEntries; i++) {
      await cache.write('$i', recipe('$i'));
    }

    expect(cache.count, RecipeCache.maxEntries);
    expect(await cache.read('0'), isNull);

    expect(await cache.read('${RecipeCache.maxEntries}'), isNotNull);
  });

  test('restores cached recipes after restart', () async {
    await cache.write('1', recipe('1'));

    final restored = RecipeCache.withStore(store);

    try {
      expect(await restored.read('1'), recipe('1'));
    } finally {
      restored.dispose();
    }
  });

  test('clears cached recipes', () async {
    await cache.write('1', recipe('1'));

    await cache.clear();

    expect(cache.count, 0);
    expect(await cache.read('1'), isNull);
  });

  test('returns cached recipe when connection fails', () async {
    final adapter = FakeRecipeAdapter();

    final dio = Dio(
      BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1'),
    );

    dio.httpClientAdapter = adapter;

    dio.interceptors.add(RecipeCacheInterceptor(cache));

    try {
      await dio.get<dynamic>('/lookup.php', queryParameters: {'i': '1'});

      adapter.offline = true;

      final response = await dio.get<dynamic>(
        '/lookup.php',
        queryParameters: {'i': '1'},
      );

      expect(response.data, recipe('1'));
      expect(response.extra['fromCache'], isTrue);
      expect(response.statusCode, 200);
    } finally {
      dio.close(force: true);
    }
  });

  test('preserves network error on cache miss', () async {
    final adapter = FakeRecipeAdapter()..offline = true;

    final dio = Dio(
      BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1'),
    );

    dio.httpClientAdapter = adapter;

    dio.interceptors.add(RecipeCacheInterceptor(cache));

    try {
      await expectLater(
        dio.get<dynamic>('/lookup.php', queryParameters: {'i': '1'}),
        throwsA(isA<DioException>()),
      );
    } finally {
      dio.close(force: true);
    }
  });

  test('cache failure does not break online recipes', () async {
    store.failOnWrite = true;

    final dio = Dio(
      BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1'),
    );

    dio.httpClientAdapter = FakeRecipeAdapter();

    dio.interceptors.add(RecipeCacheInterceptor(cache));

    try {
      final response = await dio.get<dynamic>(
        '/lookup.php',
        queryParameters: {'i': '1'},
      );

      expect(response.data, recipe('1'));
      expect(response.statusCode, 200);
    } finally {
      dio.close(force: true);
    }
  });
}
