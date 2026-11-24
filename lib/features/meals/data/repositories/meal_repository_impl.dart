import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/core/network/network_failure_mapper.dart';
import 'package:meals/features/meals/data/datasources/meal_datasource.dart';
import 'package:meals/features/meals/data/models/meal_model.dart';
import 'package:meals/features/meals/domain/repositories/meal_repository.dart';

class MealRepositoryImpl implements MealRepository {
  final MealDatasource mealDatasource;

  MealRepositoryImpl(this.mealDatasource);

  @override
  Future<Either<Failure, List<MealModel>>> getMealsByQuery(String query) {
    return _fetchList(() => mealDatasource.fetchMealsByQuery(query));
  }

  @override
  Future<Either<Failure, MealModel>> getMealsById(String id) {
    return _fetchSingle(() => mealDatasource.fetchMealById(id));
  }

  @override
  Future<Either<Failure, List<MealModel>>> listMealsByFirstLetter(
    String letter,
  ) {
    return _fetchList(() => mealDatasource.fetchMealsByFirstLetter(letter));
  }

  @override
  Future<Either<Failure, MealModel>> lookupRandomMeal() {
    return _fetchSingle(mealDatasource.fetchRandomMeal);
  }

  @override
  Future<Either<Failure, List<MealModel>>> searchMealsByName(String name) {
    return _fetchList(() => mealDatasource.fetchMealsByName(name));
  }

  Future<Either<Failure, List<MealModel>>> _fetchList(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final meals = _parseMeals(response.data);

      if (meals.isEmpty) {
        return Left(EmptyResultFailure());
      }

      return Right(meals);
    } catch (error) {
      return Left(mapNetworkFailure(error));
    }
  }

  Future<Either<Failure, MealModel>> _fetchSingle(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final meals = _parseMeals(response.data);

      if (meals.isEmpty) {
        return Left(NotFoundFailure());
      }

      return Right(meals.first);
    } catch (error) {
      return Left(mapNetworkFailure(error));
    }
  }

  List<MealModel> _parseMeals(Object? data) {
    if (data is! Map<String, dynamic> || !data.containsKey('meals')) {
      throw const FormatException('Invalid meals response.');
    }

    final meals = data['meals'];

    if (meals == null) {
      return [];
    }

    if (meals is! List) {
      throw const FormatException('Expected a meals list.');
    }

    return meals
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Invalid meal object.');
          }

          return MealModel.fromJson(item);
        })
        .toList(growable: false);
  }
}
