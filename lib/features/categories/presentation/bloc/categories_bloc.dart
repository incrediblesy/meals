import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/core/usecases/no_params.dart';
import 'package:meals/features/categories/domain/entities/category_entity.dart';
import 'package:meals/features/categories/domain/usecases/get_category_list_usecase.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({required GetCategoryListUseCase getCategoriesUsecase})
    : super(CategoriesInitial()) {
    on<FetchCategories>((event, emit) async {
      if (state is CategoriesLoading) return;

      emit(CategoriesLoading());

      final result = await getCategoriesUsecase(NoParams());

      result.fold(
        (failure) => emit(CategoriesError(failure)),
        (categories) => emit(CategoriesLoaded(categories)),
      );
    });
  }
}
