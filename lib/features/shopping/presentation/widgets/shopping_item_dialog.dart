import 'package:material_ui/material_ui.dart';

import 'package:meals/core/themes/app_tokens.dart';

import '../../domain/entities/shopping_item.dart';

class ShoppingItemDraft {
  final String name;
  final String quantity;

  const ShoppingItemDraft({required this.name, required this.quantity});
}

class ShoppingItemDialog extends StatefulWidget {
  final ShoppingItem? item;

  const ShoppingItemDialog({super.key, this.item});

  @override
  State<ShoppingItemDialog> createState() => _ShoppingItemDialogState();
}

class _ShoppingItemDialogState extends State<ShoppingItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.item?.name ?? '',
  );

  late final _quantityController = TextEditingController(
    text: widget.item?.quantity ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();

    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    Navigator.of(context).pop(
      ShoppingItemDraft(
        name: _nameController.text.trim(),
        quantity: _quantityController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit ingredient' : 'Add ingredient'),

      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(
                  labelText: 'Ingredient',
                  hintText: 'e.g. Chicken breast',
                  prefixIcon: Icon(Icons.shopping_basket_outlined),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an ingredient name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              TextFormField(
                controller: _quantityController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),

                decoration: const InputDecoration(
                  labelText: 'Quantity (optional)',
                  hintText: 'e.g. 500 g',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
            ],
          ),
        ),
      ),

      scrollable: true,

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
