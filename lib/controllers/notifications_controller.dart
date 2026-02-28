import 'package:get/get.dart';

class NotificationsController extends GetxController {
  // Orders
  final orderUpdates = true.obs;
  final deliveryStatus = true.obs;

  // Promotions
  final dealsAndOffers = true.obs;
  final newRestaurants = false.obs;

  // General
  final emailNotifications = true.obs;
  final inAppSounds = true.obs;
}
