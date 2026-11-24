import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/core/usecases/no_params.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/meals/domain/usecases/get_meal_by_id_usecase.dart';
import 'package:meals/features/meals/domain/usecases/get_meal_list_usecase.dart';
import 'package:meals/features/meals/domain/usecases/list_meals_by_first_letter_usecase.dart';
import 'package:meals/features/meals/domain/usecases/lookup_random_meal_usecase.dart';
import 'package:meals/features/meals/domain/usecases/search_meals_by_name_usecase.dart';

part 'meals_event.dart';
part 'meals_state.dart';

class MealsBloc extends Bloc<MealsEvent, MealsState> {
  MealsBloc({
    required GetMealListUseCase getMealsUsecase,
    required GetMealByIdUseCase getMealByIdUsecase,
    required ListMealsByFirstLetterUseCase listMealsByFirstLetterUsecase,
    required LookupRandomMealUseCase lookupRandomMealUsecase,
    required SearchMealsByNameUseCase searchMealsByNameUsecase,
  }) : super(MealsInitial()) {
    on<GetMealsByQuery>((event, emit) async {
      emit(MealsLoading());

      final result = await getMealsUsecase(event.query);

      result.fold(
        (failure) => emit(MealsError(failure)),
        (meals) => emit(MealsLoaded(meals)),
      );
    });

    on<GetMealById>((event, emit) async {
      emit(MealsLoading());

      final result = await getMealByIdUsecase(event.id);

      result.fold(
        (failure) => emit(MealsError(failure)),
        (meal) => emit(MealLoaded(meal)),
      );
    });

    on<ListMealsByFirstLetter>((event, emit) async {
      emit(MealsLoading());

      final result = await listMealsByFirstLetterUsecase(event.letter);

      result.fold(
        (failure) => emit(MealsError(failure)),
        (meals) => emit(MealsLoaded(meals)),
      );
    });

    on<LookupRandomMeal>((event, emit) async {
      emit(MealsLoading());

      final result = await lookupRandomMealUsecase(NoParams());

      result.fold(
        (failure) => emit(MealsError(failure)),
        (meal) => emit(RandomMealLoaded(meal)),
      );
    });

    on<SearchMealsByName>((event, emit) async {
      emit(MealsLoading());

      final result = await searchMealsByNameUsecase(event.name);

      result.fold(
        (failure) => emit(MealsError(failure)),
        (meals) => emit(MealsLoaded(meals)),
      );
    });
  }
}
