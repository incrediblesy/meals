import 'package:flutter_test/flutter_test.dart';

import 'package:meals/features/meals/presentation/widgets/cooking/cooking_steps.dart';
import 'package:meals/features/meals/presentation/widgets/cooking/cooking_timer_controller.dart';

void main() {
  group('Cooking steps', () {
    test('preserves wording and handles line endings', () {
      expect(
        parseCookingSteps(
          ' Step 1. Heat oil.\r\n\r\n'
          ' Step 2. Add rice.\rServe.\n',
        ),
        ['Step 1. Heat oil.', 'Step 2. Add rice.', 'Serve.'],
      );
    });

    test('handles null instructions', () {
      expect(parseCookingSteps(null), isEmpty);
    });

    test('handles empty instructions', () {
      expect(parseCookingSteps('  \n '), isEmpty);
    });

    test('preserves single paragraph instructions', () {
      expect(parseCookingSteps('One paragraph. Keep it intact.'), [
        'One paragraph. Keep it intact.',
      ]);
    });
  });

  group('Cooking timer', () {
    late DateTime now;
    late CookingTimerController timer;

    setUp(() {
      now = DateTime(2026, 1, 1);

      timer = CookingTimerController(now: () => now);
    });

    tearDown(() {
      timer.dispose();
    });

    test('defaults to five minutes', () {
      expect(timer.remaining, const Duration(minutes: 5));

      expect(timer.isRunning, isFalse);
      expect(timer.isFinished, isFalse);
    });

    test('configures a different duration', () {
      timer.configure(const Duration(minutes: 15));

      expect(timer.remaining, const Duration(minutes: 15));
    });

    test('starts the timer', () {
      timer.start();

      expect(timer.isRunning, isTrue);
    });

    test('pauses and resumes correctly', () {
      timer.configure(const Duration(minutes: 1));

      timer.start();

      now = now.add(const Duration(seconds: 10));

      timer.pause();

      expect(timer.remaining, const Duration(seconds: 50));

      expect(timer.isRunning, isFalse);

      now = now.add(const Duration(minutes: 1));

      timer.start();

      now = now.add(const Duration(seconds: 20));

      timer.refresh();

      expect(timer.remaining, const Duration(seconds: 30));

      expect(timer.isRunning, isTrue);
    });

    test('finishes when deadline is reached', () {
      timer.configure(const Duration(minutes: 1));

      timer.start();

      now = now.add(const Duration(seconds: 61));

      timer.refresh();

      expect(timer.remaining, Duration.zero);
      expect(timer.isFinished, isTrue);
      expect(timer.isRunning, isFalse);
    });

    test('resets to configured duration', () {
      timer.configure(const Duration(minutes: 10));

      timer.start();

      now = now.add(const Duration(minutes: 2));

      timer.refresh();

      timer.reset();

      expect(timer.remaining, const Duration(minutes: 10));

      expect(timer.isRunning, isFalse);
      expect(timer.isFinished, isFalse);
    });

    test('rejects invalid durations', () {
      timer.configure(Duration.zero);

      expect(timer.configured, const Duration(minutes: 5));
    });

    test('cannot configure while running', () {
      timer.start();

      timer.configure(const Duration(minutes: 30));

      expect(timer.configured, const Duration(minutes: 5));
    });

    test('restarts after completion', () {
      timer.configure(const Duration(minutes: 1));

      timer.start();

      now = now.add(const Duration(minutes: 2));

      timer.refresh();

      expect(timer.isFinished, isTrue);

      timer.start();

      expect(timer.isRunning, isTrue);
      expect(timer.isFinished, isFalse);

      expect(timer.remaining, const Duration(minutes: 1));
    });
  });
}
