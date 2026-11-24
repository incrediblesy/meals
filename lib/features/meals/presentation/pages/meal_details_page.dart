import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';
import 'package:meals/core/widgets/app_network_image.dart';
import 'package:meals/features/meals/domain/entities/meal_entity.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailsPage extends StatefulWidget {
  final String id;

  const MealDetailsPage({super.key, required this.id});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  @override
  void didUpdateWidget(covariant MealDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id) {
      _checkedIngredients.clear();
      _loadMeal();
    }
  }

  void _loadMeal() {
    context.read<MealsBloc>().add(GetMealById(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        if (state is MealLoaded) {
          return _buildRecipe(state.meal);
        }

        if (state is MealsError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe')),
            body: AppError(
              title: 'Unable to load recipe',
              message: state.message,
              onRetry: _loadMeal,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Recipe')),
          body: const AppLoading(message: 'Loading recipe...'),
        );
      },
    );
  }

  // ================= RECIPE =================

  Widget _buildRecipe(MealEntity meal) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(meal),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 900;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecipeTitle(meal),
                          const SizedBox(height: 24),
                          _buildQuickInfo(meal),
                          const SizedBox(height: 32),
                          if (isDesktop)
                            _buildDesktopContent(meal)
                          else
                            _buildMobileContent(meal),
                          const SizedBox(height: 32),
                          _buildRecipeLinks(meal),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildSliverHeader(MealEntity meal) {
    final width = MediaQuery.sizeOf(context).width;

    return SliverAppBar(
      expandedHeight: width >= 900 ? 420 : 300,
      pinned: true,
      stretch: true,
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF26372A),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Hero(
          tag: meal.id,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                url: meal.thumbnail,
                fit: BoxFit.cover,
                semanticLabel: meal.name,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black38,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TITLE =================

  Widget _buildRecipeTitle(MealEntity meal) {
    final theme = Theme.of(context);

    final tags = (meal.tags ?? '')
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECIPE',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          meal.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                side: BorderSide.none,
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ================= QUICK INFO =================

  Widget _buildQuickInfo(MealEntity meal) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 24,
        runSpacing: 24,
        children: [
          _buildInfoItem(
            icon: Icons.restaurant_menu_rounded,
            title: 'Category',
            value: meal.category ?? 'Unknown',
          ),
          _buildInfoItem(
            icon: Icons.public_rounded,
            title: 'Cuisine',
            value: meal.area ?? 'Unknown',
          ),
          _buildInfoItem(
            icon: Icons.shopping_basket_outlined,
            title: 'Ingredients',
            value: '${meal.ingredients.length}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ================= RESPONSIVE CONTENT =================

  Widget _buildMobileContent(MealEntity meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIngredients(meal),
        const SizedBox(height: 32),
        _buildInstructions(meal),
      ],
    );
  }

  Widget _buildDesktopContent(MealEntity meal) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildIngredients(meal)),
        const SizedBox(width: 32),
        Expanded(flex: 3, child: _buildInstructions(meal)),
      ],
    );
  }

  // ================= INGREDIENTS =================

  Widget _buildIngredients(MealEntity meal) {
    final theme = Theme.of(context);
    final total = meal.ingredients.length;

    final checked = _checkedIngredients.where((index) => index < total).length;

    final progress = total == 0 ? 0.0 : checked / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionTitle(
                'Ingredients',
                Icons.shopping_basket_outlined,
              ),
            ),
            TextButton(
              onPressed: _checkedIngredients.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _checkedIngredients.clear();
                      });
                    },
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (total == 0)
          const Text('Ingredients are unavailable.')
        else ...[
          Text(
            '$checked of $total ingredients prepared',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 20),

          ...List.generate(total, (index) {
            final ingredient = meal.ingredients[index];

            final measure = index < meal.measures.length
                ? meal.measures[index].trim()
                : '';

            return _buildIngredientTile(
              index: index,
              ingredient: ingredient,
              measure: measure,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildIngredientTile({
    required int index,
    required String ingredient,
    required String measure,
  }) {
    final theme = Theme.of(context);
    final isChecked = _checkedIngredients.contains(index);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isChecked
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
          : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: CheckboxListTile(
        value: isChecked,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _checkedIngredients.add(index);
            } else {
              _checkedIngredients.remove(index);
            }
          });
        },
        title: Text(
          ingredient,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: isChecked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isChecked
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: measure.isEmpty
            ? null
            : Text(measure, style: theme.textTheme.bodySmall),
      ),
    );
  }

  // ================= INSTRUCTIONS =================

  Widget _buildInstructions(MealEntity meal) {
    final instructions = meal.instructions?.trim() ?? '';

    final steps = instructions
        .split(RegExp(r'\r?\n'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Instructions', Icons.menu_book_rounded),
        const SizedBox(height: 20),
        if (steps.isEmpty)
          const Text('Cooking instructions are unavailable.')
        else
          ...steps.asMap().entries.map((entry) {
            return _buildInstructionStep(
              number: entry.key + 1,
              instruction: entry.value,
            );
          }),
      ],
    );
  }

  Widget _buildInstructionStep({
    required int number,
    required String instruction,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
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
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$number',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
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

  // ================= RECIPE LINKS =================

  Widget _buildRecipeLinks(MealEntity meal) {
    final videoUrl = _parseUrl(meal.youtube);
    final sourceUrl = _parseUrl(meal.source);

    if (videoUrl == null && sourceUrl == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('More about this recipe', Icons.link_rounded),
        const SizedBox(height: 16),
        if (videoUrl != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openUrl(videoUrl),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Watch video recipe'),
            ),
          ),
        if (videoUrl != null && sourceUrl != null) const SizedBox(height: 12),
        if (sourceUrl != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(sourceUrl),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('View original recipe'),
            ),
          ),
      ],
    );
  }

  Uri? _parseUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value.trim());

    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }

    return uri;
  }

  Future<void> _openUrl(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showLinkError();
      }
    } catch (_) {
      if (mounted) {
        _showLinkError();
      }
    }
  }

  void _showLinkError() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open the link.')));
  }

  // ================= SHARED =================

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
