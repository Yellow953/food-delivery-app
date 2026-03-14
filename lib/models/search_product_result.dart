import 'restaurant_model.dart';
import 'seller_product_model.dart';

/// A flat product enriched with its restaurant context, used for search results.
class SearchProductResult {
  SearchProductResult({
    required this.product,
    required this.restaurant,
  });

  final SellerProductModel product;
  final RestaurantModel restaurant;
}
