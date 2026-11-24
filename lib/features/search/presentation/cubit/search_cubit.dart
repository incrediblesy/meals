import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/features/meals/domain/usecases/get_meal_list_usecase.dart';
import 'package:meals/features/meals/domain/usecases/search_meals_by_name_usecase.dart';
import 'package:meals/features/search/data/search_filter_catalog.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMealsByNameUseCase searchMealsByName;
  final GetMealListUseCase getMealsByQuery;
  final SearchFilterCatalog filterCatalog;
  Timer? _debounce;
  int _requestId = 0;

  SearchCubit({
    required this.searchMealsByName,
    required this.getMealsByQuery,
    required this.filterCatalog,
  }) : super(const SearchState());

  // ================= SEARCH MODE =================

  void changeMode(SearchMode mode) {
    if (state.mode == mode) return;

    _debounce?.cancel();
    _requestId++;

    emit(SearchState(mode: mode));
  }

  // ================= QUERY =================

  void updateQuery(String value, {bool immediate = false}) {
    _debounce?.cancel();

    final requestId = ++_requestId;
    final query = value.trim();
    final mode = state.mode;

    if (query.length < 2) {
      emit(SearchState(mode: mode, query: query));

      return;
    }

    // Category, cuisine and ingredient filters
    // require a submitted value.
    if (mode != SearchMode.name && !immediate) {
      emit(SearchState(mode: mode, query: query));

      return;
    }

    emit(SearchState(mode: mode, query: query, status: SearchStatus.loading));

    if (immediate) {
      unawaited(_search(query, mode, requestId));

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_search(query, mode, requestId));
    });
  }

  // ================= EXECUTE SEARCH =================

  Future<void> _search(String query, SearchMode mode, int requestId) async {
    if (!_isCurrent(requestId)) return;

    try {
      String filterValue = query;

      if (mode != SearchMode.name) {
        final resolved = await filterCatalog.resolve(_filterKey(mode), query);

        if (!_isCurrent(requestId)) return;

        if (resolved == null) {
          emit(
            SearchState(mode: mode, query: query, status: SearchStatus.idle),
          );

          return;
        }

        filterValue = resolved;
      }

      final result = switch (mode) {
        SearchMode.name => await searchMealsByName(query),

        SearchMode.category => await getMealsByQuery(
          _filterQuery('c', filterValue),
        ),

        SearchMode.cuisine => await getMealsByQuery(
          _filterQuery('a', filterValue),
        ),

        SearchMode.ingredient => await getMealsByQuery(
          _filterQuery(
            'i',
            filterValue.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
          ),
        ),
      };

      if (!_isCurrent(requestId)) return;

      result.fold(
        (failure) {
          emit(
            SearchState(
              mode: mode,
              query: query,
              status: failure is EmptyResultFailure
                  ? SearchStatus.empty
                  : SearchStatus.failure,
              failure: failure,
            ),
          );
        },
        (meals) {
          emit(
            SearchState(
              mode: mode,
              query: query,
              status: meals.isEmpty ? SearchStatus.empty : SearchStatus.success,
              meals: List.unmodifiable(meals),
            ),
          );
        },
      );
    } catch (_) {
      if (!_isCurrent(requestId)) return;

      emit(
        SearchState(
          mode: mode,
          query: query,
          status: SearchStatus.failure,
          failure: ServerFailure(),
        ),
      );
    }
  }

  String _filterKey(SearchMode mode) {
    return switch (mode) {
      SearchMode.category => 'c',
      SearchMode.cuisine => 'a',
      SearchMode.ingredient => 'i',
      SearchMode.name => throw ArgumentError(
        'Name search does not use a filter catalog.',
      ),
    };
  }

  Future<List<String>> filterSuggestions(SearchMode mode, String query) {
    if (mode == SearchMode.name) {
      return Future.value(const <String>[]);
    }

    return filterCatalog.suggestions(_filterKey(mode), query);
  }

  String _filterQuery(String key, String value) {
    return Uri(queryParameters: {key: value}).query;
  }

  bool _isCurrent(int requestId) {
    return !isClosed && requestId == _requestId;
  }

  // ================= ACTIONS =================

  void retry() {
    updateQuery(state.query, immediate: true);
  }

  void clear() {
    updateQuery('');
  }

  // ================= DISPOSE =================

  @override
  Future<void> close() {
    _debounce?.cancel();
    _requestId++;

    return super.close();
  }
}
