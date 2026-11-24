import 'package:dio/dio.dart';

import '../constants/constants.dart';
import 'network_info.dart';

class NetworkService {
  final Dio _dio;
  final NetworkInfo networkInfo;

  NetworkService(this.networkInfo, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 10),
            ),
          );

  Future<Response> getRequest(String url) async {
    if (!await networkInfo.isConnected) {
      throw DioException(
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
        requestOptions: RequestOptions(path: url),
      );
    }
    return _dio.get(url);
  }
}
