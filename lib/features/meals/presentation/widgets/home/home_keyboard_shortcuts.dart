import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'home_navigation.dart';

class HomeKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final ValueChanged<HomeTab> onTabSelected;

  const HomeKeyboardShortcuts({
    super.key,
    required this.child,
    required this.focusNode,
    required this.onSearch,
    required this.onTabSelected,
  });

  static const _tabKeys = {
    HomeTab.discover: LogicalKeyboardKey.digit1,
    HomeTab.categories: LogicalKeyboardKey.digit2,
    HomeTab.favorites: LogicalKeyboardKey.digit3,
    HomeTab.shopping: LogicalKeyboardKey.digit4,
    HomeTab.planner: LogicalKeyboardKey.digit5,
    HomeTab.settings: LogicalKeyboardKey.digit6,
  };

  static String get searchHint =>
      defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd+K' : 'Ctrl+K';

  SingleActivator _shortcut(LogicalKeyboardKey key) {
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;

    return SingleActivator(
      key,
      control: !isMac,
      meta: isMac,
      includeRepeats: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        _shortcut(LogicalKeyboardKey.keyK): onSearch,

        for (final entry in _tabKeys.entries)
          _shortcut(entry.value): () {
            onTabSelected(entry.key);
          },
      },

      child: Focus(
        focusNode: focusNode,
        autofocus: true,
        skipTraversal: true,
        child: child,
      ),
    );
  }
}
