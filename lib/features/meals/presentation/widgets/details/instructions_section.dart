import 'package:material_ui/material_ui.dart';

import '../cooking/cooking_steps.dart';
import 'recipe_section_title.dart';

class InstructionsSection extends StatelessWidget {
  final String? instructions;

  const InstructionsSection({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    final steps = parseCookingSteps(instructions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RecipeSectionTitle(
          title: 'Instructions',
          icon: Icons.menu_book_rounded,
        ),

        const SizedBox(height: 20),

        if (steps.isEmpty)
          const Text('Cooking instructions are unavailable.')
        else
          for (var i = 0; i < steps.length; i++)
            _InstructionStep(number: i + 1, instruction: steps[i]),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String instruction;

  const _InstructionStep({required this.number, required this.instruction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),

      color: colors.surfaceContainerLow,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                '$number',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: SelectableText(
                instruction,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
