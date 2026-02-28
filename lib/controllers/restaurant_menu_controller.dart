import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:url_launcher/url_launcher.dart';

import '../models/popular_dish_model.dart';
import '../models/restaurant_model.dart';
import 'main_controller.dart';

/// Shows a restaurant and its menu (dishes). Receives [RestaurantModel] via Get.arguments.
/// Menu items use the global popular dishes for now (no per-restaurant menu in Firestore yet).
class RestaurantMenuController extends GetxController {
  RestaurantMenuController(this._mainController);

  final MainController _mainController;

  RestaurantModel? get restaurant => _restaurant;
  RestaurantModel? _restaurant;

  List<PopularDishModel> get menuDishes => _mainController.popularDishes;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RestaurantModel) {
      _restaurant = args;
    }
  }

  void openDish(PopularDishModel dish) {
    Get.toNamed<void>(
      '/product-detail',
      arguments: dish,
    );
  }

  bool isFavoriteDish(String dishId) => _mainController.isFavoriteDish(dishId);

  void toggleFavoriteDish(String dishId) {
    _mainController.toggleFavoriteDish(dishId);
    update();
  }

  /// Open restaurant location in maps (Google Maps search).
  Future<void> openMaps() async {
    final r = _restaurant;
    if (r == null) return;
    final query = Uri.encodeComponent(r.address ?? r.name);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Share restaurant name and text.
  /// [sharePositionOrigin] is required on iOS to anchor the share sheet popover.
  Future<void> shareRestaurant([Rect? sharePositionOrigin]) async {
    final r = _restaurant;
    if (r == null) return;
    await Share.share(
      'Check out ${r.name} - ${r.cuisine}. ${r.address ?? ''}',
      subject: r.name,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Open WhatsApp chat with restaurant phone (wa.me).
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
}
