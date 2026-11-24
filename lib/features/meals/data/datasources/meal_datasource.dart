import 'package:dio/dio.dart';
import 'package:meals/core/network/network_service.dart';

class MealDatasource {
  final NetworkService networkService;
  MealDatasource(this.networkService);

  Future<Response> fetchMealsByQuery(String query) =>
      networkService.getRequest('/filter.php?$query');
  Future<Response> fetchMealById(String id) => networkService.getRequest(
    '/lookup.php?i=${Uri.encodeQueryComponent(id)}',
  );
  Future<Response> fetchMealsByFirstLetter(String letter) => networkService
      .getRequest('/search.php?f=${Uri.encodeQueryComponent(letter)}');
  Future<Response> fetchRandomMeal() =>
      networkService.getRequest('/random.php');
  Future<Response> fetchMealsByName(String name) => networkService.getRequest(
    '/search.php?s=${Uri.encodeQueryComponent(name.trim())}',
  );
}
