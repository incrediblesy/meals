import 'package:dio/dio.dart';

import '../constants/constants.dart';

class NetworkService {
  final Dio _dio;

  NetworkService({Dio? dio})
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
          );

  Future<Response<dynamic>> getRequest(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<dynamic>(path, queryParameters: queryParameters);
  }
}
