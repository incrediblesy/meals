import 'package:meals/features/categories/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    super.name,
    super.thumbnail,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = _readString(json['idCategory']);
    final name = _readString(json['strCategory']);

    if (id == null || name == null) {
      throw const FormatException('Category ID and name are required.');
    }

    return CategoryModel(
      id: id,
      name: name,
      thumbnail: _readString(json['strCategoryThumb']),
      description: _readString(json['strCategoryDescription']),
    );
  }

  Map<String, dynamic> toJson() => {
    'idCategory': id,
    'strCategory': name,
    'strCategoryThumb': thumbnail,
    'strCategoryDescription': description,
  };

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      thumbnail: entity.thumbnail,
      description: entity.description,
    );
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;

    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }
}
