import 'package:flutter_test/flutter_test.dart';
import 'package:meals/features/meals/data/models/meal_model.dart';

void main() {
  group('MealModel.fromJson', () {
    test('parses basic meal data', () {
      final meal = MealModel.fromJson({
        'idMeal': '123',
        'strMeal': 'Chicken Soup',
        'strCategory': 'Chicken',
        'strArea': 'British',
      });

      expect(meal.id, '123');
      expect(meal.name, 'Chicken Soup');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'British');
    });

    test('keeps ingredients and measurements aligned', () {
      final meal = MealModel.fromJson({
        'idMeal': '123',
        'strMeal': 'Chicken Rice',
        'strIngredient1': 'Chicken',
        'strMeasure1': '500 g',
        'strIngredient2': 'Salt',
        'strMeasure2': null,
        'strIngredient3': 'Rice',
        'strMeasure3': '200 g',
      });

      expect(meal.ingredients, ['Chicken', 'Salt', 'Rice']);

      expect(meal.measures, ['500 g', '', '200 g']);
    });

    test('ignores empty ingredients', () {
      final meal = MealModel.fromJson({
        'idMeal': '123',
        'strMeal': 'Soup',
        'strIngredient1': '   ',
        'strIngredient2': null,
        'strIngredient3': '  Onion  ',
        'strMeasure3': '  2  ',
      });

      expect(meal.ingredients, ['Onion']);
      expect(meal.measures, ['2']);
    });

    test('handles partial meal responses', () {
      final meal = MealModel.fromJson({'idMeal': '123', 'strMeal': 'Pasta'});

      expect(meal.ingredients, isEmpty);
      expect(meal.measures, isEmpty);
      expect(meal.instructions, isNull);
      expect(meal.isFavorite, isFalse);
    });

    test('rejects missing meal ID', () {
      expect(
        () => MealModel.fromJson({'strMeal': 'Pasta'}),
        throwsFormatException,
      );
    });

    test('rejects missing meal name', () {
      expect(
        () => MealModel.fromJson({'idMeal': '123'}),
        throwsFormatException,
      );
    });
  });
}
