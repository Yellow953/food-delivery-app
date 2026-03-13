import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:url_launcher/url_launcher.dart';

import '../models/restaurant_model.dart';
import '../models/seller_product_model.dart';
import 'cart_controller.dart';
import 'main_controller.dart';

/// Shows a restaurant and its menu. Receives [RestaurantModel] via Get.arguments.
/// Menu items are loaded from restaurants/{id}/products in Firestore.
class RestaurantMenuController extends GetxController {
  RestaurantMenuController(this._mainController, this._firestore);

  final MainController _mainController;
  final FirebaseFirestore? _firestore;

  RestaurantModel? get restaurant => _restaurant;
  RestaurantModel? _restaurant;

  final RxList<SellerProductModel> menuProducts = <SellerProductModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RestaurantModel) {
      _restaurant = args;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  void _listen() {
    final db = _firestore;
    final rid = _restaurant?.id;
    if (db == null || rid == null || rid.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _sub = db
        .collection('restaurants')
        .doc(rid)
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .listen(
          (snap) {
            menuProducts.assignAll(
              snap.docs
                  .map((d) => SellerProductModel.fromFirestore(d))
                  .toList(),
            );
            isLoading.value = false;
          },
          onError: (_) => isLoading.value = false,
        );
  }

  void openProduct(SellerProductModel product) {
    final cart = Get.find<CartController>();
    if (_restaurant != null) {
      cart.restaurantId = _restaurant!.id;
      cart.restaurantName = _restaurant!.name;
    }
    Get.toNamed<void>('/product-detail', arguments: product);
  }

  bool isFavoriteDish(String id) => _mainController.isFavoriteDish(id);

  void toggleFavoriteDish(String id) {
    _mainController.toggleFavoriteDish(id);
    update();
  }

  /// Open restaurant location in Google Maps.
  Future<void> openMaps() async {
    final r = _restaurant;
    if (r == null) return;
    final query = Uri.encodeComponent(r.address ?? r.name);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Share restaurant details.
  Future<void> shareRestaurant([Rect? sharePositionOrigin]) async {
    final r = _restaurant;
    if (r == null) return;
    await Share.share(
      'Check out ${r.name} - ${r.cuisine}. ${r.address ?? ''}',
      subject: r.name,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Open WhatsApp chat with restaurant phone.
  Future<void> contactWhatsApp() async {
    final r = _restaurant;
    if (r == null) return;
    final phone = (r.phone ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (phone.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
