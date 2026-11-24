import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';

import '../../domain/entities/meal_entity.dart';
import '../widgets/cooking/cooking_steps.dart';
import '../widgets/cooking/cooking_timer.dart';
import '../widgets/cooking/cooking_timer_controller.dart';
import '../widgets/details/ingredients_section.dart';

class CookingPage extends StatefulWidget {
  final MealEntity meal;
  final Set<int> preparedIngredients;

  const CookingPage({
    super.key,
    required this.meal,
    this.preparedIngredients = const {},
  });

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  late final List<String> _steps = parseCookingSteps(widget.meal.instructions);

  late final Set<int> _checked = Set.of(widget.preparedIngredients);

  final _timer = CookingTimerController();

  int _index = 0;
  bool _finished = false;
  bool _showIngredients = false;

  @override
  void dispose() {
    _timer.dispose();

    super.dispose();
  }

  // ================= NAVIGATION =================

  void _previous() {
    setState(() {
      if (_finished) {
        _finished = false;
      } else if (_index > 0) {
        _index--;
      }
    });
  }

  void _next() {
    setState(() {
      if (_index < _steps.length - 1) {
        _index++;
      } else {
        _finished = true;
      }
    });
  }

  // ================= PAGE =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cooking mode')),

      body: SafeArea(
        top: false,
        child: _steps.isEmpty
            ? const AppEmpty(
                title: 'No cooking instructions',
                icon: Icons.menu_book_outlined,
                message:
                    'This recipe does not contain '
                    'cooking instructions.',
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: SizedBox.expand(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.meal.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge,
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              Text(
                                _finished
                                    ? 'Recipe complete'
                                    : 'Step ${_index + 1} of ${_steps.length}',
                                style: theme.textTheme.labelLarge,
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              LinearProgressIndicator(
                                value: _finished ? 1 : _index / _steps.length,
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 760;

                              final instruction = _buildInstruction(context);

                              final tools = _buildTools();

                              return ListView(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                children: [
                                  if (wide)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(flex: 3, child: instruction),

                                        const SizedBox(width: AppSpacing.lg),

                                        Expanded(flex: 2, child: tools),
                                      ],
                                    )
                                  else ...[
                                    instruction,

                                    const SizedBox(height: AppSpacing.lg),

                                    tools,
                                  ],
                                ],
                              );
                            },
                          ),
                        ),

                        const Divider(height: 1),

                        _buildNavigation(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ================= INSTRUCTION =================

  Widget _buildInstruction(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _finished
                  ? Icons.check_circle_outline_rounded
                  : Icons.menu_book_rounded,

              color: theme.colorScheme.primary,
              size: 40,
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              _finished ? 'Enjoy your meal!' : 'Step ${_index + 1}',

              style: theme.textTheme.headlineSmall,
            ),

            const SizedBox(height: AppSpacing.md),

            SelectableText(
              _finished
                  ? 'You have reached the end of the recipe.'
                  : _steps[_index],

              style: theme.textTheme.titleLarge?.copyWith(
                height: 1.6,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COOKING TOOLS =================

  Widget _buildTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CookingTimer(controller: _timer),

        const SizedBox(height: AppSpacing.lg),

        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _showIngredients = !_showIngredients;
            });
          },

          icon: Icon(
            _showIngredients
                ? Icons.expand_less_rounded
                : Icons.shopping_basket_outlined,
          ),

          label: Text(
            _showIngredients
                ? 'Hide ingredients'
                : 'Ingredients (${_checked.length}/${widget.meal.ingredients.length})',
          ),
        ),

        if (_showIngredients) ...[
          const SizedBox(height: AppSpacing.md),

          IngredientsSection(
            meal: widget.meal,
            checked: _checked,

            onToggle: (index) {
              setState(() {
                if (!_checked.add(index)) {
                  _checked.remove(index);
                }
              });
            },

            onReset: () => setState(_checked.clear),
          ),
        ],
      ],
    );
  }

  // ================= BOTTOM NAVIGATION =================

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _index == 0 && !_finished ? null : _previous,

              icon: const Icon(Icons.arrow_back_rounded),

              label: Text(_finished ? 'Review' : 'Previous'),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: FilledButton.icon(
              onPressed: _finished ? () => Navigator.of(context).pop() : _next,

              icon: Icon(
                _finished || _index == _steps.length - 1
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
              ),

              label: Text(
                _finished
                    ? 'Done'
                    : _index == _steps.length - 1
                    ? 'Finish'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
