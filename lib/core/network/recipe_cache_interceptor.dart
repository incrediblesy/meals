import 'package:dio/dio.dart';

import '../cache/recipe_cache.dart';

class RecipeCacheInterceptor extends Interceptor {
  final RecipeCache cache;

  RecipeCacheInterceptor(this.cache);

  String? _recipeId(RequestOptions options) {
    if (options.method.toUpperCase() != 'GET') {
      return null;
    }

    final uri = options.uri;

    if (!uri.path.endsWith('/lookup.php')) {
      return null;
    }

    final id = uri.queryParameters['i']?.trim();

    if (id == null || id.isEmpty) {
      return null;
    }

    return id;
  }

  // ================= ONLINE RESPONSE =================

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final id = _recipeId(response.requestOptions);

    if (id != null && response.statusCode == 200) {
      try {
        await cache.write(id, response.data);
      } catch (_) {
        // Cache errors must never prevent a valid
        // online recipe from being displayed.
      }
    }

    handler.next(response);
  }

  // ================= OFFLINE FALLBACK =================

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final id = _recipeId(err.requestOptions);

    if (id == null || !_canFallback(err)) {
      handler.next(err);
      return;
    }

    try {
      final cached = await cache.read(id);

      if (cached != null) {
        handler.resolve(
          Response<dynamic>(
            requestOptions: err.requestOptions,
            data: cached,
            statusCode: 200,
            extra: const {'fromCache': true},
          ),
        );

        return;
      }
    } catch (_) {
      // Preserve the original network error if
      // local cache reading also fails.
    }

    handler.next(err);
  }

  bool _canFallback(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,

      DioExceptionType.badResponse => (error.response?.statusCode ?? 0) >= 500,

      _ => false,
    };
  }
}
