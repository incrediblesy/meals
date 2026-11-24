import 'package:material_ui/material_ui.dart';
import 'package:meals/core/widgets/app_network_image.dart';
import 'package:meals/features/favorites/presentation/widgets/favorite_button.dart';

import '../../../domain/entities/meal_entity.dart';

class RecipeHeader extends StatelessWidget {
  final MealEntity meal;
  const RecipeHeader({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SliverAppBar(
      expandedHeight: width >= 900 ? 420 : 300,
      pinned: true,
      stretch: true,
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF26372A),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FavoriteButton(meal: meal),
        ),
      ],
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
}
