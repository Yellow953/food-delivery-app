import 'package:get/get.dart';

import '../models/cart_item_model.dart';

/// Permanent singleton that holds the user's cart across the session.
class CartController extends GetxController {
  static const double deliveryFee = 2.99;

  final RxList<CartItem> items = <CartItem>[].obs;

  int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get total => subtotal + deliveryFee;

  /// Adds an item. If the same dish+size is already in cart, increments quantity.
  void addItem(CartItem item) {
    final idx = items.indexWhere(
      (i) => i.dish.id == item.dish.id && i.sizeName == item.sizeName,
    );
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(item);
    }
  }

  void increment(int index) {
    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
  }

  void decrement(int index) {
    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] =
          items[index].copyWith(quantity: items[index].quantity - 1);
    }
  }

  void remove(int index) {
    items.removeAt(index);
  }

  void clear() {
    items.clear();
  }
}
