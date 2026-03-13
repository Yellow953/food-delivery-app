import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../models/cart_item_model.dart';
import '../models/seller_product_model.dart';
import 'cart_controller.dart';
import 'main_controller.dart';

/// Shows a single product; receives [SellerProductModel] via Get.arguments.
/// Handles the product's real variant groups from Firestore.
class ProductDetailController extends GetxController {
  ProductDetailController(this._mainController);

  final MainController _mainController;

  SellerProductModel? get product => _product;
  SellerProductModel? _product;

  /// groupIndex → set of selected option indices.
  /// Single-choice groups always have at most one element.
  final Map<int, Set<int>> selectedVariants = {};

  bool get isFavorite =>
      _product != null && _mainController.isFavoriteDish(_product!.id);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is SellerProductModel) {
      _product = args;
      _initSelections();
    }
  }

  void _initSelections() {
    final groups = _product?.variantGroups ?? [];
    for (var i = 0; i < groups.length; i++) {
      // Auto-select first option for single-choice groups
      selectedVariants[i] =
          groups[i].isSingle && groups[i].options.isNotEmpty ? {0} : {};
    }
  }

  // ─── Pricing ────────────────────────────────────────────────────────────────

  double get variantTotal {
    double total = _product?.basePrice ?? 0;
    final groups = _product?.variantGroups ?? [];
    selectedVariants.forEach((groupIdx, optionIndices) {
      if (groupIdx < groups.length) {
        for (final optIdx in optionIndices) {
          if (optIdx < groups[groupIdx].options.length) {
            total += groups[groupIdx].options[optIdx].additionalPrice;
          }
        }
      }
    });
    return total;
  }

  String get variantPriceLabel => '\$${variantTotal.toStringAsFixed(2)}';

  /// Human-readable summary of all selected options, e.g. "Medium · Extra cheese"
  String get variantSummary {
    final parts = <String>[];
    final groups = _product?.variantGroups ?? [];
    for (var i = 0; i < groups.length; i++) {
      for (final optIdx in (selectedVariants[i] ?? {})) {
        if (optIdx < groups[i].options.length) {
          parts.add(groups[i].options[optIdx].name);
        }
      }
    }
    return parts.join(' · ');
  }

  // ─── Selection helpers ──────────────────────────────────────────────────────

  void selectOption(int groupIndex, int optionIndex) {
    final groups = _product?.variantGroups ?? [];
    if (groupIndex >= groups.length) return;
    final group = groups[groupIndex];
    if (group.isSingle) {
      selectedVariants[groupIndex] = {optionIndex};
    } else {
      final current = Set<int>.from(selectedVariants[groupIndex] ?? {});
      if (current.contains(optionIndex)) {
        current.remove(optionIndex);
      } else {
        current.add(optionIndex);
      }
      selectedVariants[groupIndex] = current;
    }
    update();
  }

  bool isOptionSelected(int groupIndex, int optionIndex) =>
      selectedVariants[groupIndex]?.contains(optionIndex) ?? false;

  // ─── Actions ────────────────────────────────────────────────────────────────

  void toggleFavorite() {
    if (_product != null) {
      _mainController.toggleFavoriteDish(_product!.id);
      update();
    }
  }

  void addToCart() {
    final p = _product;
    if (p == null) return;
    Get.find<CartController>().addItem(CartItem(
      product: p,
      variantSummary: variantSummary,
      price: variantTotal,
    ));
    Get.offNamed<void>(AppRoutes.checkout);
  }
}
