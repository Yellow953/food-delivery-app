import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../services/auth_service.dart';

class DriverOrdersController extends GetxController {
  DriverOrdersController(this._authService, this._firestore);

  final AuthService _authService;
  final FirebaseFirestore? _firestore;

  /// Orders ready_for_pickup (not yet taken by a driver)
  final RxList<OrderModel> availableOrders = <OrderModel>[].obs;

  /// My active delivery (on_the_way with my driverId)
  final RxList<OrderModel> myActiveOrders = <OrderModel>[].obs;

  /// My delivered orders
  final RxList<OrderModel> myHistoryOrders = <OrderModel>[].obs;

  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _availableSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activeSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historySub;

  String? get _uid => _authService.currentUser.value?.uid;

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  void _listen() {
    final db = _firestore;
    final uid = _uid;
    if (db == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _availableSub = db
        .collection('orders')
        .where('status', isEqualTo: 'ready_for_pickup')
        .snapshots()
        .listen((snap) {
      // Filter out orders that already have a driverId
      final list = snap.docs
          .map((d) => OrderModel.fromFirestore(d))
          .where((o) => (o.driverId ?? '').isEmpty)
          .toList()
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      availableOrders.assignAll(list);
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });

    if (uid != null) {
      _activeSub = db
          .collection('orders')
          .where('status', isEqualTo: 'on_the_way')
          .where('driverId', isEqualTo: uid)
          .snapshots()
          .listen((snap) {
        final list = snap.docs
            .map((d) => OrderModel.fromFirestore(d))
            .toList()
          ..sort((a, b) =>
              (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        myActiveOrders.assignAll(list);
      });

      _historySub = db
          .collection('orders')
          .where('status', isEqualTo: 'delivered')
          .where('driverId', isEqualTo: uid)
          .snapshots()
          .listen((snap) {
        final list = snap.docs
            .map((d) => OrderModel.fromFirestore(d))
            .toList()
          ..sort((a, b) =>
              (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        myHistoryOrders.assignAll(list);
      });
    }
  }

  Future<void> pickUpOrder(String orderId) async {
    final db = _firestore;
    final uid = _uid;
    if (db == null || uid == null) return;
    await db.collection('orders').doc(orderId).update({
      'status': 'on_the_way',
      'driverId': uid,
    });
  }

  Future<void> markDelivered(String orderId) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('orders').doc(orderId).update({'status': 'delivered'});
  }

  @override
  void onClose() {
    _availableSub?.cancel();
    _activeSub?.cancel();
    _historySub?.cancel();
    super.onClose();
  }
}
