import 'package:equatable/equatable.dart';

class SearchHistoryEntry extends Equatable {
  final String query;
  final String mode;

  const SearchHistoryEntry({required this.query, required this.mode});

  String get id => '$mode:${query.trim().toLowerCase()}';

  @override
  List<Object?> get props => [query, mode];
}
