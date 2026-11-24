import '../entities/search_history_entry.dart';

abstract interface class SearchHistoryRepository {
  Future<List<SearchHistoryEntry>> load();

  Future<void> save(List<SearchHistoryEntry> entries);
}
