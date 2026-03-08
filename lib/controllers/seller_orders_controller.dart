import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../services/user_service.dart';

class SellerOrdersController extends GetxController {
  SellerOrdersController(this._firestore);

  final FirebaseFirestore? _firestore;

  /// Active orders: pending, accepted, preparing, ready_for_pickup
  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;

  /// Completed/rejected orders
  final RxList<OrderModel> historyOrders = <OrderModel>[].obs;

  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activeSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historySub;

  static const List<String> activeStatuses = [
    'pending', 'accepted', 'preparing', 'ready_for_pickup',
  ];
  static const List<String> historyStatuses = ['delivered', 'rejected'];

  String? get _restaurantId => Get.find<UserService>().restaurantId;

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  void _listen() {
    final db = _firestore;
    final rid = _restaurantId;
    if (db == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    // Build query — if no restaurantId assigned yet, show all orders (for dev)
    Query<Map<String, dynamic>> activeQuery = db.collection('orders');
    Query<Map<String, dynamic>> historyQuery = db.collection('orders');

    if (rid != null && rid.isNotEmpty) {
      activeQuery = activeQuery.where('restaurantId', isEqualTo: rid);
      historyQuery = historyQuery.where('restaurantId', isEqualTo: rid);
    }

    _activeSub = activeQuery
        .where('status', whereIn: activeStatuses)
        .snapshots()
        .listen((snap) {
      final list = snap.docs
          .map((d) => OrderModel.fromFirestore(d))
          .toList()
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      activeOrders.assignAll(list);
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });

    _historySub = historyQuery
        .where('status', whereIn: historyStatuses)
        .snapshots()
        .listen((snap) {
      final list = snap.docs
          .map((d) => OrderModel.fromFirestore(d))
          .toList()
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      historyOrders.assignAll(list);
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  @override
  void onClose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    super.onClose();
  }
}
