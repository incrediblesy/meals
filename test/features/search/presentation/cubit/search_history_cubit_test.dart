import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/search/domain/entities/search_history_entry.dart';
import 'package:meals/features/search/domain/repositories/search_history_repository.dart';
import 'package:meals/features/search/presentation/cubit/search_history_cubit.dart';

class FakeSearchHistoryRepository implements SearchHistoryRepository {
  List<SearchHistoryEntry> stored = [];

  bool failOnSave = false;

  @override
  Future<List<SearchHistoryEntry>> load() async {
    return List.of(stored);
  }

  @override
  Future<void> save(List<SearchHistoryEntry> entries) async {
    if (failOnSave) {
      throw Exception('Save failed');
    }

    stored = List.of(entries);
  }
}

void main() {
  late FakeSearchHistoryRepository repository;
  late SearchHistoryCubit cubit;

  setUp(() async {
    repository = FakeSearchHistoryRepository();

    cubit = SearchHistoryCubit(repository: repository);

    await cubit.load();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('records submitted search', () async {
    await cubit.record(query: 'Chicken', mode: 'name');

    expect(cubit.state.entries.length, 1);
    expect(repository.stored.single.query, 'Chicken');
  });

  test('ignores empty or short queries', () async {
    await cubit.record(query: '', mode: 'name');
    await cubit.record(query: 'A', mode: 'name');

    expect(cubit.state.entries, isEmpty);
  });

  test('deduplicates case-insensitive queries', () async {
    await cubit.record(query: 'Chicken', mode: 'name');

    await cubit.record(query: ' chicken ', mode: 'name');

    expect(cubit.state.entries.length, 1);
  });

  test('preserves different search modes', () async {
    await cubit.record(query: 'Chicken', mode: 'name');

    await cubit.record(query: 'Chicken', mode: 'category');

    expect(cubit.state.entries.length, 2);
  });

  test('moves repeated searches to the top', () async {
    await cubit.record(query: 'Chicken', mode: 'name');
    await cubit.record(query: 'Pasta', mode: 'name');
    await cubit.record(query: 'Chicken', mode: 'name');

    expect(cubit.state.entries.first.query, 'Chicken');
    expect(cubit.state.entries.length, 2);
  });

  test('limits history to twenty entries', () async {
    for (var i = 0; i < 25; i++) {
      await cubit.record(query: 'Recipe $i', mode: 'name');
    }

    expect(cubit.state.entries.length, 20);
    expect(cubit.state.entries.first.query, 'Recipe 24');
    expect(cubit.state.entries.last.query, 'Recipe 5');
  });

  test('removes an individual entry', () async {
    await cubit.record(query: 'Pasta', mode: 'name');

    await cubit.remove(cubit.state.entries.single.id);

    expect(cubit.state.entries, isEmpty);
  });

  test('clears all history', () async {
    await cubit.record(query: 'Pasta', mode: 'name');
    await cubit.record(query: 'Italian', mode: 'cuisine');

    await cubit.clear();

    expect(cubit.state.entries, isEmpty);
    expect(repository.stored, isEmpty);
  });

  test('serializes concurrent writes', () async {
    await Future.wait([
      cubit.record(query: 'Chicken', mode: 'name'),
      cubit.record(query: 'Pasta', mode: 'name'),
      cubit.record(query: 'Italian', mode: 'cuisine'),
    ]);

    expect(cubit.state.entries.length, 3);
    expect(cubit.state.entries.first.query, 'Italian');
    expect(repository.stored.length, 3);
  });

  test('preserves history on storage failure', () async {
    await cubit.record(query: 'Pasta', mode: 'name');

    repository.failOnSave = true;

    await cubit.record(query: 'Chicken', mode: 'name');

    expect(cubit.state.entries.length, 1);
    expect(cubit.state.entries.single.query, 'Pasta');
    expect(cubit.state.error, isNotNull);
  });

  test('restores persisted history', () async {
    await cubit.record(query: 'Italian', mode: 'cuisine');

    final restored = SearchHistoryCubit(repository: repository);

    try {
      await restored.load();

      expect(restored.state.entries.single.query, 'Italian');
      expect(restored.state.entries.single.mode, 'cuisine');
    } finally {
      await restored.close();
    }
  });
}
