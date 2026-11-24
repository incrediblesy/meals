import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/meals/presentation/widgets/home/home_navigation.dart';

void main() {
  Future<void> buildNavigation(
    WidgetTester tester, {
    required double width,
    HomeTab selectedTab = HomeTab.discover,
    required ValueChanged<HomeTab> onChanged,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 800));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: HomeNavigationBar(
            selectedTab: selectedTab,
            onChanged: onChanged,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('compact navigation has four destinations', (tester) async {
    await buildNavigation(tester, width: 400, onChanged: (_) {});

    expect(find.byType(NavigationDestination), findsNWidgets(4));

    expect(find.text('More'), findsOneWidget);
    expect(find.text('Shopping'), findsNothing);
  });

  testWidgets('tablet navigation has six destinations', (tester) async {
    await buildNavigation(tester, width: 800, onChanged: (_) {});

    expect(find.byType(NavigationDestination), findsNWidgets(6));

    expect(find.text('More'), findsNothing);
  });

  testWidgets('primary destination invokes its callback', (tester) async {
    HomeTab? selected;

    await buildNavigation(
      tester,
      width: 400,
      onChanged: (tab) => selected = tab,
    );

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(selected, HomeTab.favorites);
  });

  testWidgets('More menu allows selecting Shopping', (tester) async {
    HomeTab? selected;

    await buildNavigation(
      tester,
      width: 400,
      onChanged: (tab) => selected = tab,
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();

    expect(selected, HomeTab.shopping);
  });

  testWidgets('secondary tab selects More destination', (tester) async {
    await buildNavigation(
      tester,
      width: 400,
      selectedTab: HomeTab.settings,
      onChanged: (_) {},
    );

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));

    expect(navigation.selectedIndex, 3);
  });
}
