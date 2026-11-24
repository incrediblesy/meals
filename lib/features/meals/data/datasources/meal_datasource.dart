import 'package:dio/dio.dart';
import 'package:meals/core/network/network_service.dart';

class MealDatasource {
  final NetworkService networkService;

  MealDatasource(this.networkService);

  Future<Response<dynamic>> fetchMealsByQuery(String query) {
    return networkService.getRequest(
      '/filter.php',
      queryParameters: Uri.splitQueryString(query),
    );
  }

  Future<Response<dynamic>> fetchMealById(String id) {
    return networkService.getRequest('/lookup.php', queryParameters: {'i': id});
  }

  Future<Response<dynamic>> fetchMealsByFirstLetter(String letter) {
    return networkService.getRequest(
      '/search.php',
      queryParameters: {'f': letter},
    );
  }

  Future<Response<dynamic>> fetchRandomMeal() {
    return networkService.getRequest('/random.php');
  }

  Future<Response<dynamic>> fetchMealsByName(String name) {
    return networkService.getRequest(
      '/search.php',
      queryParameters: {'s': name.trim()},
    );
  }
}
