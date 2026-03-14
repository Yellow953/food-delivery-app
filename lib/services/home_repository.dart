import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/popular_dish_model.dart';
import '../models/restaurant_model.dart';
import '../models/search_product_result.dart';
import '../models/seller_product_model.dart';
import 'firestore_seed_service.dart';

/// Fetches home screen data from Firestore. Ensures seed runs once.
class HomeRepository {
  HomeRepository(this._firestore, this._seedService);

  final FirebaseFirestore _firestore;
  final FirestoreSeedService _seedService;

  static const String _banners = 'banners';
  static const String _popularDishes = 'popular_dishes';
  static const String _categories = 'categories';
  static const String _restaurants = 'restaurants';

  /// Runs seed if needed, then returns banners sorted by order.
  Future<List<BannerModel>> getBanners() async {
    await _seedService.seedIfNeeded();
    final snapshot = await _firestore
        .collection(_banners)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((d) => BannerModel.fromFirestore(d))
        .toList();
  }

  /// Returns popular dishes sorted by order.
  Future<List<PopularDishModel>> getPopularDishes() async {
    await _seedService.seedIfNeeded();
    final snapshot = await _firestore
        .collection(_popularDishes)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((d) => PopularDishModel.fromFirestore(d))
        .toList();
  }

  /// Returns categories sorted by order.
  Future<List<CategoryModel>> getCategories() async {
    await _seedService.seedIfNeeded();
    final snapshot = await _firestore
        .collection(_categories)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((d) => CategoryModel.fromFirestore(d))
        .toList();
  }

  /// Returns restaurants sorted by order.
  Future<List<RestaurantModel>> getRestaurants() async {
    await _seedService.seedIfNeeded();
    final snapshot = await _firestore
        .collection(_restaurants)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((d) => RestaurantModel.fromFirestore(d))
        .toList();
  }

  /// Fetches all available products from every restaurant in parallel.
  Future<List<SearchProductResult>> getAllProducts(
      List<RestaurantModel> restaurants) async {
    if (restaurants.isEmpty) return [];
    final futures = restaurants.map((r) async {
      try {
        final snap = await _firestore
            .collection(_restaurants)
            .doc(r.id)
            .collection('products')
            .where('isAvailable', isEqualTo: true)
            .orderBy('order')
            .get();
        return snap.docs
            .map((doc) => SearchProductResult(
                  product: SellerProductModel.fromFirestore(doc),
                  restaurant: r,
                ))
            .toList();
      } catch (_) {
        return <SearchProductResult>[];
      }
    });
    final lists = await Future.wait(futures);
    return lists.expand((l) => l).toList();
  }

  /// Stream of banners for reactive updates.
  Stream<List<BannerModel>> watchBanners() {
    return _firestore
        .collection(_banners)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => BannerModel.fromFirestore(d)).toList());
  }

  Stream<List<PopularDishModel>> watchPopularDishes() {
    return _firestore
        .collection(_popularDishes)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => PopularDishModel.fromFirestore(d)).toList());
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _firestore
        .collection(_categories)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => CategoryModel.fromFirestore(d)).toList());
  }

  Stream<List<RestaurantModel>> watchRestaurants() {
    return _firestore
        .collection(_restaurants)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => RestaurantModel.fromFirestore(d)).toList());
  }
}
