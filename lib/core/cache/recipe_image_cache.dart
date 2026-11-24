import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:material_ui/material_ui.dart';

class RecipeImageCache {
  RecipeImageCache._();

  static final CacheManager manager = CacheManager(
    Config(
      'meals-recipe-images-v1',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );

  static Future<void> clear() async {
    if (!kIsWeb) {
      await manager.emptyCache();
    }

    PaintingBinding.instance.imageCache.clear();
  }
}
