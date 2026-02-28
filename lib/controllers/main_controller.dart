import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/popular_dish_model.dart';
import '../models/restaurant_model.dart';
import '../services/auth_service.dart';
import '../services/home_repository.dart';
import 'cart_controller.dart';

/// Controls main shell: bottom nav index, auth, and home data from Firestore.
class MainController extends GetxController {
  MainController(this._authService, this._homeRepository);

  final AuthService _authService;
  final HomeRepository? _homeRepository;

  final RxInt currentIndex = 0.obs;

  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxList<PopularDishModel> popularDishes = <PopularDishModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxBool homeDataLoading = true.obs;
  final RxBool restaurantsLoading = true.obs;

  /// Favorite dish IDs (in-memory; could be persisted to Firestore/local later).
  final RxList<String> favoriteDishIds = <String>[].obs;

  /// Search query for search tab (restaurants + dishes).
  final Rx<String> searchQuery = ''.obs;

  /// Cart item count — reads from the permanent CartController.
  int get cartItemCount => Get.find<CartController>().totalItemCount;

  String? get userEmail => _authService.currentUser.value?.email;

  /// Filtered restaurants by current search query.
  List<RestaurantModel> get filteredRestaurants {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return restaurants;
    return restaurants
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q))
        .toList();
  }

  /// Filtered dishes by current search query.
  List<PopularDishModel> get filteredDishes {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return popularDishes;
    return popularDishes
        .where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.subtitle.toLowerCase().contains(q))
        .toList();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  void setIndex(int index) {
    currentIndex.value = index;
  }

  void toggleFavoriteDish(String dishId) {
    if (favoriteDishIds.contains(dishId)) {
      favoriteDishIds.remove(dishId);
    } else {
      favoriteDishIds.add(dishId);
    }
  }

  bool isFavoriteDish(String dishId) => favoriteDishIds.contains(dishId);

  @override
  void onReady() {
    super.onReady();
    _loadHomeData();
    _loadRestaurants();
  }

  Future<void> _loadHomeData() async {
    if (_homeRepository == null) {
      homeDataLoading.value = false;
      return;
    }
    homeDataLoading.value = true;
    try {
      banners.assignAll(await _homeRepository!.getBanners());
      popularDishes.assignAll(await _homeRepository!.getPopularDishes());
      categories.assignAll(await _homeRepository!.getCategories());
    } catch (_) {
      // Keep empty lists on error
    } finally {
      homeDataLoading.value = false;
    }
  }

  Future<void> _loadRestaurants() async {
    if (_homeRepository == null) {
      restaurantsLoading.value = false;
      return;
    }
    restaurantsLoading.value = true;
    try {
      restaurants.assignAll(await _homeRepository!.getRestaurants());
    } catch (_) {
      // Keep empty list on error
    } finally {
      restaurantsLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed<void>(AppRoutes.auth);
  }
}
