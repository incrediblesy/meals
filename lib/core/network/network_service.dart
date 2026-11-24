import 'package:dio/dio.dart';
import 'package:meals/core/cache/recipe_cache.dart';
import 'package:meals/core/network/recipe_cache_interceptor.dart';

import '../constants/constants.dart';

class NetworkService {
  final Dio _dio;

  NetworkService({Dio? dio, RecipeCache? recipeCache})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
              headers: {'Accept': 'application/json'},
            ),
          ) {
    if (recipeCache != null) {
      _dio.interceptors.add(RecipeCacheInterceptor(recipeCache));
    }
  }

  Future<Response<dynamic>> getRequest(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<dynamic>(path, queryParameters: queryParameters);
  }
}
