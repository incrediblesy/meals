import 'package:dio/dio.dart';

import '../errors/failures.dart';

Failure mapNetworkFailure(Object error) {
  if (error is FormatException) {
    return InvalidResponseFailure();
  }

  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => TimeoutFailure(),

      DioExceptionType.connectionError => NetworkFailure(),

      _ => ServerFailure(),
    };
  }

  return ServerFailure();
}
