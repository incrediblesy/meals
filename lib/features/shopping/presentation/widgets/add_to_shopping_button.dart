import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meals/features/meals/domain/entities/meal_entity.dart';

import '../cubit/shopping_cubit.dart';
import '../cubit/shopping_state.dart';

class AddToShoppingButton extends StatelessWidget {
  final MealEntity meal;

  const AddToShoppingButton({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                !state.canModify ||
                    meal.ingredients.every(
                      (ingredient) => ingredient.trim().isEmpty,
                    )
                ? null
                : () async {
                    final cubit = context.read<ShoppingCubit>();

                    final success = await cubit.addMeal(meal);

                    if (!context.mounted) return;

                    final messenger = ScaffoldMessenger.of(context);

                    messenger.hideCurrentSnackBar();

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Ingredients added to shopping list.'
                              : 'Unable to add ingredients.',
                        ),
                      ),
                    );
                  },

            icon: const Icon(Icons.add_shopping_cart_rounded),

            label: const Text('Add to shopping list'),
          ),
        );
      },
    );
  }
}
