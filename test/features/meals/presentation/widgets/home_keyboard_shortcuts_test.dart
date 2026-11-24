import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/meals/presentation/widgets/home/home_keyboard_shortcuts.dart';
import 'package:meals/features/meals/presentation/widgets/home/home_navigation.dart';

void main() {
  testWidgets('Ctrl+K opens search on Windows', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    final focusNode = FocusNode();
    var searchCount = 0;

    addTearDown(() {
      focusNode.dispose();
      debugDefaultTargetPlatformOverride = null;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeKeyboardShortcuts(
          focusNode: focusNode,
          onSearch: () => searchCount++,
          onTabSelected: (_) {},
          child: const Scaffold(),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(searchCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Ctrl+5 selects Planner', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;

    final focusNode = FocusNode();
    HomeTab? selected;

    addTearDown(() {
      focusNode.dispose();
      debugDefaultTargetPlatformOverride = null;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeKeyboardShortcuts(
          focusNode: focusNode,
          onSearch: () {},
          onTabSelected: (tab) => selected = tab,
          child: const Scaffold(),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);

    await tester.sendKeyEvent(LogicalKeyboardKey.digit5);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    expect(selected, HomeTab.planner);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
