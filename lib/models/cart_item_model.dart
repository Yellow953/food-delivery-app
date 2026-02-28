import 'popular_dish_model.dart';

class CartItem {
  CartItem({
    required this.dish,
    required this.sizeName,
    required this.price,
    required this.addons,
    this.quantity = 1,
  });

  final PopularDishModel dish;
  final String sizeName;
  final double price; // unit price including size offset
  final List<String> addons;
  final int quantity;

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        dish: dish,
        sizeName: sizeName,
        price: price,
        addons: addons,
        quantity: quantity ?? this.quantity,
      );
}
