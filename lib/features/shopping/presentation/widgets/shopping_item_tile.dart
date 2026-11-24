import 'package:material_ui/material_ui.dart';

import '../../domain/entities/shopping_item.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.enabled,
    required this.onToggle,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: item.isPurchased ? colors.surfaceContainerLow : null,

      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onToggle : null,

        leading: Checkbox(
          value: item.isPurchased,
          onChanged: enabled ? (_) => onToggle() : null,
        ),

        title: Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: item.isPurchased
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: item.isPurchased
                ? colors.onSurfaceVariant
                : colors.onSurface,
          ),
        ),

        subtitle: item.quantity.isEmpty
            ? null
            : Text(
                item.quantity,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

        trailing: PopupMenuButton<String>(
          enabled: enabled,
          tooltip: 'Item actions',

          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'remove':
                onRemove();
                break;
            }
          },

          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),

            PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.delete_outline_rounded),
                title: Text('Remove'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
