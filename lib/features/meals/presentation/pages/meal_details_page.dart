import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/widgets/recipe_image.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailsPage extends StatefulWidget {
  const MealDetailsPage({super.key, required this.id});
  final String id;
  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  final Set<int> _checked = {};
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => context.read<MealsBloc>().add(GetMealById(widget.id));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        if (state is MealsError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load this recipe.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is! MealLoaded) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final meal = state.meal;
        final theme = Theme.of(context);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: meal.id,
                    child: RecipeImage(url: meal.thumbnail),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (meal.category?.trim().isNotEmpty ?? false)
                                Chip(label: Text(meal.category!)),
                              if (meal.area?.trim().isNotEmpty ?? false)
                                Chip(label: Text(meal.area!)),
                              Chip(
                                label: Text(
                                  '${meal.ingredients.length} ingredients',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (_, constraints) {
                              if (constraints.maxWidth >= 700) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _ingredients(meal)),
                                    const SizedBox(width: 32),
                                    Expanded(child: _instructions(meal)),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ingredients(meal),
                                  const SizedBox(height: 28),
                                  _instructions(meal),
                                ],
                              );
                            },
                          ),
                          if (meal.youtube?.trim().isNotEmpty ?? false) ...[
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: () => _watch(meal.youtube!),
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Watch video recipe'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ingredients(MealEntity meal) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      if (meal.ingredients.isEmpty) const Text('Ingredients are unavailable.'),
      ...List.generate(meal.ingredients.length, (index) {
        final measure = index < meal.measures.length
            ? meal.measures[index]
            : '';
        final checked = _checked.contains(index);
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: checked,
          onChanged: (value) => setState(() {
            if (value == true) {
              _checked.add(index);
            } else {
              _checked.remove(index);
            }
          }),
          title: Text(
            meal.ingredients[index],
            style: TextStyle(
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: measure.isEmpty ? null : Text(measure),
        );
      }),
    ],
  );

  Widget _instructions(MealEntity meal) {
    final text = meal.instructions?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SelectableText(
          text.isEmpty ? 'No instructions available.' : text,
          style: const TextStyle(height: 1.6),
        ),
      ],
    );
  }

  Future<void> _watch(String link) async {
    final uri = Uri.tryParse(link);
    try {
      if (uri != null &&
          uri.scheme == 'https' &&
          await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Report a failed external launch without interrupting the recipe.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open video.')));
  }
}
