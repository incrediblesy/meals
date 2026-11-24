import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/features/meals/data/datasources/meal_datasource.dart';
import 'package:meals/features/meals/data/models/meal_model.dart';
import 'package:meals/features/meals/domain/repositories/meal_repository.dart';

class MealRepositoryImpl implements MealRepository {
  final MealDatasource mealDatasource;
  MealRepositoryImpl(this.mealDatasource);

  List<MealModel> _parse(Response response) {
    final rows = response.data['meals'] as List? ?? const [];
    return rows.map((row) => MealModel.fromJson(Map<String, dynamic>.from(row as Map))).toList();
  }

  Future<Either<Failure, List<MealModel>>> _list(Future<Response> Function() fetch) async {
    try {
      return Right(_parse(await fetch()));
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, MealModel>> _single(Future<Response> Function() fetch) async {
    try {
      final meals = _parse(await fetch());
      if (meals.isEmpty) return Left(EmptyResultFailure());
      return Right(meals.first);
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MealModel>>> getMealsByQuery(String query) =>
      _list(() => mealDatasource.fetchMealsByQuery(query));
  @override
  Future<Either<Failure, MealModel>> getMealsById(String id) =>
      _single(() => mealDatasource.fetchMealById(id));
  @override
  Future<Either<Failure, List<MealModel>>> listMealsByFirstLetter(String letter) =>
      _list(() => mealDatasource.fetchMealsByFirstLetter(letter));
  @override
  Future<Either<Failure, MealModel>> lookupRandomMeal() => _single(mealDatasource.fetchRandomMeal);
  @override
  Future<Either<Failure, List<MealModel>>> searchMealsByName(String name) =>
      _list(() => mealDatasource.fetchMealsByName(name));
}
