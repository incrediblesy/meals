import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/core/themes/app_tokens.dart';
import 'package:meals/core/widgets/app_empty.dart';
import 'package:meals/core/widgets/app_error.dart';
import 'package:meals/core/widgets/app_loading.dart';

import '../../domain/entities/shopping_item.dart';
import '../cubit/shopping_cubit.dart';
import '../cubit/shopping_state.dart';
import '../widgets/shopping_item_dialog.dart';
import '../widgets/shopping_item_tile.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  Future<void> _openItemDialog(
    BuildContext context, {
    ShoppingItem? item,
  }) async {
    final result = await showDialog<ShoppingItemDraft>(
      context: context,
      builder: (_) => ShoppingItemDialog(item: item),
    );

    if (!context.mounted || result == null) return;

    final cubit = context.read<ShoppingCubit>();

    if (item == null) {
      await cubit.addItem(name: result.name, quantity: result.quantity);
    } else {
      await cubit.editItem(
        item.id,
        name: result.name,
        quantity: result.quantity,
      );
    }
  }

  Future<void> _clearPurchased(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear purchased items?'),
        content: const Text(
          'All purchased items will be removed. '
          'Pending ingredients will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) return;

    await context.read<ShoppingCubit>().clearPurchased();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        return switch (state.status) {
          ShoppingStatus.initial || ShoppingStatus.loading => const AppLoading(
            message: 'Loading shopping list...',
          ),

          ShoppingStatus.failure => AppError(
            title: 'Shopping list unavailable',
            message: state.error ?? 'Unable to load shopping items.',
            onRetry: context.read<ShoppingCubit>().load,
          ),

          ShoppingStatus.ready => _buildContent(context, state),
        };
      },
    );
  }

  Widget _buildContent(BuildContext context, ShoppingState state) {
    final cubit = context.read<ShoppingCubit>();

    return ListView(
      key: const PageStorageKey<String>('shopping-page'),
      padding: const EdgeInsets.all(AppSpacing.xl),

      children: [
        _buildHeader(context),

        const SizedBox(height: AppSpacing.xl),

        _buildProgress(context, state),

        const SizedBox(height: AppSpacing.lg),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,

          children: [
            FilledButton.icon(
              onPressed: state.canModify
                  ? () => _openItemDialog(context)
                  : null,

              icon: const Icon(Icons.add_rounded),
              label: const Text('Add item'),
            ),

            OutlinedButton.icon(
              onPressed: state.canModify && state.purchasedCount > 0
                  ? () => _clearPurchased(context)
                  : null,

              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Clear purchased'),
            ),
          ],
        ),

        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.md),

          Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        if (state.items.isEmpty)
          AppEmpty(
            title: 'Your shopping list is empty',
            icon: Icons.shopping_cart_outlined,
            message:
                'Add ingredients manually or directly '
                'from your favorite recipes.',
            actionLabel: 'Add ingredient',
            onAction: state.canModify ? () => _openItemDialog(context) : null,
          )
        else ...[
          if (state.pendingItems.isNotEmpty) ...[
            _buildSectionTitle(context, 'To buy', state.remainingCount),

            const SizedBox(height: AppSpacing.sm),

            for (final item in state.pendingItems)
              ShoppingItemTile(
                key: ValueKey(item.id),
                item: item,
                enabled: state.canModify,
                onToggle: () => cubit.togglePurchased(item.id),
                onEdit: () => _openItemDialog(context, item: item),
                onRemove: () => cubit.removeItem(item.id),
              ),

            const SizedBox(height: AppSpacing.xl),
          ],

          if (state.purchasedItems.isNotEmpty) ...[
            _buildSectionTitle(context, 'Purchased', state.purchasedCount),

            const SizedBox(height: AppSpacing.sm),

            for (final item in state.purchasedItems)
              ShoppingItemTile(
                key: ValueKey(item.id),
                item: item,
                enabled: state.canModify,
                onToggle: () => cubit.togglePurchased(item.id),
                onEdit: () => _openItemDialog(context, item: item),
                onRemove: () => cubit.removeItem(item.id),
              ),
          ],
        ],

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR GROCERIES',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text('Shopping list', style: theme.textTheme.headlineMedium),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Everything you need for your next meal.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context, ShoppingState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),

      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.total == 0
                      ? 'Ready to shop?'
                      : state.remainingCount == 0
                      ? 'All done!'
                      : '${state.remainingCount} items left',

                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),

              Icon(
                state.total > 0 && state.remainingCount == 0
                    ? Icons.check_circle_outline_rounded
                    : Icons.shopping_cart_outlined,
                color: colors.onPrimaryContainer,
                size: 32,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            '${state.purchasedCount} of ${state.total} purchased',

            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          LinearProgressIndicator(
            value: state.isSaving ? null : state.progress,
            color: colors.primary,
            backgroundColor: colors.onPrimaryContainer.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(title, style: theme.textTheme.titleLarge),

        const SizedBox(width: AppSpacing.sm),

        Text(
          '($count)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
