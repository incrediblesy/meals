import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';

import 'cooking_timer_controller.dart';

class CookingTimer extends StatelessWidget {
  final CookingTimerController controller;

  const CookingTimer({super.key, required this.controller});

  String _format(Duration duration) {
    final seconds = (duration.inMilliseconds / 1000).ceil();

    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');

    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final running = controller.isRunning;
        final remaining = controller.remaining;

        final progress =
            (remaining.inMilliseconds / controller.configured.inMilliseconds)
                .clamp(0.0, 1.0)
                .toDouble();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: colors.primary),

                    const SizedBox(width: AppSpacing.sm),

                    Expanded(
                      child: Text(
                        'Cooking timer',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  _format(remaining),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),

                const SizedBox(height: AppSpacing.sm),

                LinearProgressIndicator(value: progress),

                if (controller.isFinished) ...[
                  const SizedBox(height: AppSpacing.sm),

                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'Time is up!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final minutes in [1, 5, 10, 15, 30])
                      ChoiceChip(
                        label: Text('$minutes min'),
                        selected:
                            controller.configured == Duration(minutes: minutes),
                        onSelected: running
                            ? null
                            : (_) => controller.configure(
                                Duration(minutes: minutes),
                              ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: running ? controller.pause : controller.start,

                      icon: Icon(
                        running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),

                      label: Text(
                        running
                            ? 'Pause'
                            : remaining == Duration.zero ||
                                  remaining == controller.configured
                            ? 'Start'
                            : 'Resume',
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: controller.reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
