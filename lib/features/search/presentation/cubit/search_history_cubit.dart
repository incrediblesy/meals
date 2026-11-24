import 'package:bloc/bloc.dart';

import '../../domain/entities/search_history_entry.dart';
import '../../domain/repositories/search_history_repository.dart';

class SearchHistoryState {
  final List<SearchHistoryEntry> entries;
  final bool isLoading;
  final bool isReady;
  final String? error;

  const SearchHistoryState({
    this.entries = const [],
    this.isLoading = false,
    this.isReady = false,
    this.error,
  });
}

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  final SearchHistoryRepository repository;

  static const int maxEntries = 20;

  Future<void> _pending = Future<void>.value();

  SearchHistoryCubit({required this.repository})
    : super(const SearchHistoryState());

  Future<void> _enqueue(Future<void> Function() operation) {
    _pending = _pending.then((_) async {
      if (!isClosed) {
        await operation();
      }
    });

    return _pending;
  }

  Future<void> load() => _enqueue(_load);

  Future<void> _load() async {
    if (state.isReady) return;

    emit(const SearchHistoryState(isLoading: true));

    try {
      final entries = await repository.load();

      if (isClosed) return;

      emit(
        SearchHistoryState(
          entries: List.unmodifiable(entries.take(maxEntries)),
          isReady: true,
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(const SearchHistoryState(error: 'Unable to load search history.'));
    }
  }

  Future<void> record({required String query, required String mode}) {
    return _enqueue(() async {
      query = query.trim();

      if (query.length < 2) return;

      if (!state.isReady) {
        await _load();
      }

      if (isClosed || !state.isReady) return;

      final entry = SearchHistoryEntry(query: query, mode: mode);

      final updated = [
        entry,
        ...state.entries.where((item) => item.id != entry.id),
      ].take(maxEntries).toList();

      await _save(updated);
    });
  }

  Future<void> remove(String id) {
    return _enqueue(() async {
      if (!state.isReady) return;

      await _save(state.entries.where((entry) => entry.id != id).toList());
    });
  }

  Future<void> clear() {
    return _enqueue(() async {
      if (!state.isReady) return;

      await _save(const []);
    });
  }

  Future<void> _save(List<SearchHistoryEntry> entries) async {
    try {
      await repository.save(entries);

      if (isClosed) return;

      emit(
        SearchHistoryState(entries: List.unmodifiable(entries), isReady: true),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        SearchHistoryState(
          entries: state.entries,
          isReady: true,
          error: 'Unable to save search history.',
        ),
      );
    }
  }
}
