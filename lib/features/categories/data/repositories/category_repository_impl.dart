import 'package:dartz/dartz.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/core/network/network_failure_mapper.dart';
import 'package:meals/features/categories/data/datasources/category_datasource.dart';
import 'package:meals/features/categories/data/models/category_model.dart';
import 'package:meals/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource categoryDatasource;

  CategoryRepositoryImpl(this.categoryDatasource);

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    try {
      final response = await categoryDatasource.fetchCategories();
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid category response.');
      }

      final categories = data['categories'];

      if (categories is! List) {
        throw const FormatException('Expected a category list.');
      }

      final result = categories
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid category object.');
            }

            return CategoryModel.fromJson(item);
          })
          .toList(growable: false);

      return Right(result);
    } catch (error) {
      return Left(mapNetworkFailure(error));
    }
  }
}
