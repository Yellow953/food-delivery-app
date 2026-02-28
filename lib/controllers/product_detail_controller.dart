import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../models/cart_item_model.dart';
import '../models/popular_dish_model.dart';
import 'cart_controller.dart';
import 'main_controller.dart';

/// Shows a single dish; receives [PopularDishModel] via Get.arguments.
/// Handles variants: size and add-ons.
class ProductDetailController extends GetxController {
  ProductDetailController(this._mainController);

  final MainController _mainController;

  PopularDishModel? get dish => _dish;
  PopularDishModel? _dish;

  static const List<String> sizeLabels = ['Small', 'Medium', 'Large'];
  static const List<double> sizePriceOffsets = [0, 2, 4];
  static const List<String> addonLabels = ['Extra cheese', 'Spicy sauce', 'Garlic bread'];
  static const List<double> addonPrices = [1.5, 0.5, 2.0];

  int selectedSizeIndex = 1; // Medium
  final Set<int> selectedAddonIndices = {};

  bool get isFavorite => _dish != null && _mainController.isFavoriteDish(_dish!.id);

  double get _basePrice {
    if (_dish?.price == null) return 0;
    final s = _dish!.price.replaceFirst(r'$', '').trim();
    return double.tryParse(s) ?? 0;
  }

  double get variantTotal {
    final sizeExtra = selectedSizeIndex < sizePriceOffsets.length
        ? sizePriceOffsets[selectedSizeIndex]
        : 0.0;
    final addonsExtra = selectedAddonIndices.fold<double>(
      0,
      (sum, i) => sum + (i < addonPrices.length ? addonPrices[i] : 0),
    );
    return _basePrice + sizeExtra + addonsExtra;
  }

  String get variantPriceLabel {
    if (variantTotal == _basePrice) return _dish?.price ?? '\$0';
    return '\$${variantTotal.toStringAsFixed(2)}';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PopularDishModel) {
      _dish = args;
    }
  }

  void toggleFavorite() {
    if (_dish != null) {
      _mainController.toggleFavoriteDish(_dish!.id);
      update();
    }
  }

  void selectSize(int index) {
    selectedSizeIndex = index;
    update();
  }

  void toggleAddon(int index) {
    if (selectedAddonIndices.contains(index)) {
      selectedAddonIndices.remove(index);
    } else {
      selectedAddonIndices.add(index);
    }
    update();
  }

  bool isAddonSelected(int index) => selectedAddonIndices.contains(index);

  void addToCart() {
    if (_dish == null) return;
    final cart = Get.find<CartController>();
    cart.addItem(CartItem(
      dish: _dish!,
      sizeName: sizeLabels[selectedSizeIndex],
      price: variantTotal,
      addons: selectedAddonIndices
          .map((i) => addonLabels[i])
          .toList(),
    ));
    Get.offNamed<void>(AppRoutes.checkout);
  }
}
