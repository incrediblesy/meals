import 'package:get_it/get_it.dart';
import 'package:meals/core/cache/recipe_cache.dart';
import 'package:meals/features/planner/data/repositories/planner_repository_impl.dart';
import 'package:meals/features/planner/domain/repositories/planner_repository.dart';
import 'package:meals/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:meals/features/search/data/repositories/search_history_repository_impl.dart';
import 'package:meals/features/search/domain/repositories/search_history_repository.dart';
import 'package:meals/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:meals/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:meals/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:meals/features/shopping/presentation/cubit/shopping_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:meals/core/constants/assets.dart';
import 'package:meals/core/errors/failures.dart';
import 'package:meals/core/network/network_service.dart';
import 'package:meals/core/router/app_router.dart';
import 'package:meals/core/themes/app_theme.dart';
import 'package:meals/core/utils/input_converter.dart';

// Categories
import 'package:meals/features/categories/data/datasources/category_datasource.dart';
import 'package:meals/features/categories/data/repositories/category_repository_impl.dart';
import 'package:meals/features/categories/domain/repositories/category_repository.dart';
import 'package:meals/features/categories/domain/usecases/get_category_list_usecase.dart';
import 'package:meals/features/categories/presentation/bloc/categories_bloc.dart';

// Meals
import 'package:meals/features/meals/data/datasources/meal_datasource.dart';
import 'package:meals/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:meals/features/meals/domain/repositories/meal_repository.dart';
import 'package:meals/features/meals/domain/usecases/get_meal_by_id_usecase.dart';
import 'package:meals/features/meals/domain/usecases/get_meal_list_usecase.dart';
import 'package:meals/features/meals/domain/usecases/list_meals_by_first_letter_usecase.dart';
import 'package:meals/features/meals/domain/usecases/lookup_random_meal_usecase.dart';
import 'package:meals/features/meals/domain/usecases/search_meals_by_name_usecase.dart';
import 'package:meals/features/meals/presentation/bloc/meals_bloc.dart';

// Search
import 'package:meals/features/search/data/search_filter_catalog.dart';
import 'package:meals/features/search/presentation/cubit/search_cubit.dart';

// Favorites
import 'package:meals/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:meals/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:meals/features/favorites/presentation/cubit/favorites_cubit.dart';

// Settings
import 'package:meals/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:meals/features/settings/domain/repositories/settings_repository.dart';
import 'package:meals/features/settings/presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

void init() {
  _registerCore();
  _registerCategories();
  _registerMeals();
  _registerSearch();
  _registerFavorites();
  _registerSettings();
  _registerShopping();
  _registerPlanner();
}

// ================= CORE =================

void _registerCore() {
  sl.registerLazySingleton<NetworkService>(
    () => NetworkService(recipeCache: sl()),
  );

  sl.registerLazySingleton<SharedPreferencesAsync>(
    () => SharedPreferencesAsync(),
  );

  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  sl.registerLazySingleton<AppTheme>(() => AppTheme());

  sl.registerLazySingleton<Assets>(() => Assets());

  sl.registerLazySingleton<InputConverter>(() => InputConverter());

  sl.registerLazySingleton<Failure>(
    () => ServerFailure(),
    instanceName: 'server',
  );

  sl.registerLazySingleton<Failure>(
    () => CacheFailure(),
    instanceName: 'cache',
  );

  sl.registerLazySingleton<RecipeCache>(
    () => RecipeCache(sl<SharedPreferencesAsync>()),
    dispose: (cache) => cache.dispose(),
  );
}

// ================= CATEGORIES =================

void _registerCategories() {
  // Data sources
  sl.registerLazySingleton<CategoryDatasource>(() => CategoryDatasource(sl()));

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton<GetCategoryListUseCase>(
    () => GetCategoryListUseCase(sl()),
  );

  // Presentation
  sl.registerFactory<CategoriesBloc>(
    () => CategoriesBloc(getCategoriesUsecase: sl()),
  );
}

// ================= MEALS =================

void _registerMeals() {
  // Data sources
  sl.registerLazySingleton<MealDatasource>(() => MealDatasource(sl()));

  // Repositories
  sl.registerLazySingleton<MealRepository>(() => MealRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton<GetMealListUseCase>(() => GetMealListUseCase(sl()));

  sl.registerLazySingleton<GetMealByIdUseCase>(() => GetMealByIdUseCase(sl()));

  sl.registerLazySingleton<ListMealsByFirstLetterUseCase>(
    () => ListMealsByFirstLetterUseCase(sl()),
  );

  sl.registerLazySingleton<LookupRandomMealUseCase>(
    () => LookupRandomMealUseCase(sl()),
  );

  sl.registerLazySingleton<SearchMealsByNameUseCase>(
    () => SearchMealsByNameUseCase(sl()),
  );

  // Presentation
  sl.registerFactory<MealsBloc>(
    () => MealsBloc(
      getMealsUsecase: sl(),
      getMealByIdUsecase: sl(),
      listMealsByFirstLetterUsecase: sl(),
      lookupRandomMealUsecase: sl(),
      searchMealsByNameUsecase: sl(),
    ),
  );
}

// ================= SEARCH =================

void _registerSearch() {
  sl.registerLazySingleton<SearchFilterCatalog>(
    () => SearchFilterCatalog(sl()),
  );

  sl.registerFactory<SearchCubit>(
    () => SearchCubit(
      searchMealsByName: sl(),
      getMealsByQuery: sl(),
      filterCatalog: sl(),
    ),
  );

  sl.registerLazySingleton<SearchHistoryRepository>(
    () => SearchHistoryRepositoryImpl(sl()),
  );

  sl.registerFactory<SearchHistoryCubit>(
    () => SearchHistoryCubit(repository: sl()),
  );
}

// ================= FAVORITES =================

void _registerFavorites() {
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl()),
  );

  sl.registerFactory<FavoritesCubit>(() => FavoritesCubit(repository: sl()));
}

// ================= SETTINGS =================

void _registerSettings() {
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  sl.registerFactory<SettingsCubit>(() => SettingsCubit(repository: sl()));
}

// ================= SHOPPING =================

void _registerShopping() {
  sl.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepositoryImpl(sl()),
  );

  sl.registerFactory<ShoppingCubit>(() => ShoppingCubit(repository: sl()));
}

// ================ PLANNER =================

void _registerPlanner() {
  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(sl()),
  );

  sl.registerFactory<PlannerCubit>(() => PlannerCubit(repository: sl()));
}
