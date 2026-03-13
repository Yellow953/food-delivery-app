import 'seller_product_model.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.variantSummary,
    required this.price,
    this.quantity = 1,
  });

  final SellerProductModel product;
  final String variantSummary;
  final double price; // unit price including variant extras
  final int quantity;

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        variantSummary: variantSummary,
        price: price,
        quantity: quantity ?? this.quantity,
      );
}
