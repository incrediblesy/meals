import 'package:material_ui/material_ui.dart';
import 'package:meals/core/themes/app_tokens.dart';

import '../cubit/search_state.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final SearchState state;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  const SearchInput({
    super.key,
    required this.controller,
    required this.state,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hint = switch (state.mode) {
      SearchMode.name => 'Search recipes...',
      SearchMode.category => 'Search categories...',
      SearchMode.cuisine => 'Search cuisines...',
      SearchMode.ingredient => 'Search ingredients...',
    };
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: state.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.filled(
          tooltip: 'Search',
          onPressed: state.query.length < 2 ? null : onSubmit,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    );
  }
}
