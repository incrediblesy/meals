import 'package:flutter_test/flutter_test.dart';
import 'package:meals/features/meals/data/models/meal_model.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';

void main() {
  final payload = <String, dynamic>{
    'idMeal': '1', 'strMeal': 'Soup',
    'strIngredient1': ' Onion ', 'strMeasure1': null,
    'strIngredient2': '  ', 'strMeasure2': 'ignored',
    'strIngredient3': 'Carrot', 'strMeasure3': ' 2 ',
    'strIngredient4': 'Water', 'strMeasure4': '',
  };

  test('ingredient quantities retain the same indexes', () {
    final meal = MealModel.fromJson(payload);
    expect(meal.ingredients, ['Onion', 'Carrot', 'Water']);
    expect(meal.measures, ['', '2', '']);
    expect(() => meal.ingredients.add('Salt'), throwsUnsupportedError);
  });

  test('legacy entity parser produces aligned quantities', () {
    final meal = MealEntity.fromJson(payload);
    expect(meal.ingredients, ['Onion', 'Carrot', 'Water']);
    expect(meal.measures, ['', '2', '']);
  });

  test('summary payload can omit all recipe details', () {
    final meal = MealModel.fromJson({'idMeal': '2', 'strMeal': 'Pasta'});
    expect(meal.instructions, isNull);
    expect(meal.ingredients, isEmpty);
    expect(meal.measures, isEmpty);
  });
}
