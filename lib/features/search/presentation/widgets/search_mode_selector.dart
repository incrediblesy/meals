import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';

import '../cubit/search_state.dart';

class SearchModeSelector extends StatelessWidget {
  final SearchMode mode;
  final ValueChanged<SearchMode> onChanged;
  const SearchModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in SearchMode.values)
          ChoiceChip(
            selected: item == mode,
            showCheckmark: false,
            avatar: Icon(_icon(item), size: 18),
            label: Text(_label(item)),
            onSelected: (selected) {
              if (selected) onChanged(item);
            },
          ),
      ],
    );
  }

  String _label(SearchMode mode) => switch (mode) {
    SearchMode.name => 'Name',
    SearchMode.category => 'Category',
    SearchMode.cuisine => 'Cuisine',
    SearchMode.ingredient => 'Ingredient',
  };

  IconData _icon(SearchMode mode) => switch (mode) {
    SearchMode.name => Icons.search_rounded,
    SearchMode.category => Icons.grid_view_rounded,
    SearchMode.cuisine => Icons.public_rounded,
    SearchMode.ingredient => Icons.shopping_basket_outlined,
  };
}
