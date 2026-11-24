import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  String get message;

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  @override
  String get message => 'Something went wrong. Please try again.';
}

class NetworkFailure extends Failure {
  @override
  String get message => 'Unable to connect. Check your internet connection.';
}

class TimeoutFailure extends Failure {
  @override
  String get message => 'The request timed out. Please try again.';
}

class EmptyResultFailure extends Failure {
  @override
  String get message => 'No meals found.';
}

class NotFoundFailure extends Failure {
  @override
  String get message => 'The requested recipe was not found.';
}

class InvalidResponseFailure extends Failure {
  @override
  String get message => 'The server returned an unexpected response.';
}

class CacheFailure extends Failure {
  @override
  String get message => 'Unable to load locally stored data.';
}

class InvalidInputFailure extends Failure {
  @override
  String get message => 'Please enter a valid value.';
}
