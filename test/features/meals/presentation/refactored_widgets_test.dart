import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/meals/presentation/widgets/details/ingredients_section.dart';
import 'package:meals/features/meals/presentation/widgets/details/instructions_section.dart';
import 'package:meals/features/meals/presentation/widgets/meal_grid.dart';

void main() {
  testWidgets('recipe grid adapts to available width', (tester) async {
    Future<void> pumpAt(double width) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: 400,
              child: const MealGrid(meals: []),
            ),
          ),
        ),
      ),
    );
    int columns() =>
        (tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount;
    await pumpAt(300);
    expect(columns(), 1);
    await pumpAt(700);
    expect(columns(), 3);
  });

  testWidgets('missing instructions display a fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: InstructionsSection(instructions: null)),
      ),
    );
    expect(find.text('Cooking instructions are unavailable.'), findsOneWidget);
  });

  testWidgets('ingredient checkbox delegates to the page', (tester) async {
    const meal = MealEntity(
      id: '1',
      name: 'Soup',
      ingredients: ['Salt'],
      measures: [''],
    );
    int? toggled;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IngredientsSection(
            meal: meal,
            checked: const {},
            onToggle: (index) => toggled = index,
            onReset: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CheckboxListTile));
    expect(toggled, 0);
  });
}
