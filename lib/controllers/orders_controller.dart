import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../services/auth_service.dart';

class OrdersController extends GetxController {
  OrdersController(this._authService, this._firestore);

  final AuthService _authService;
  final FirebaseFirestore? _firestore;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  @override
  Future<void> refresh() => _listen();

  Future<void> _listen() async {
    final uid = _authService.currentUser.value?.uid;
    if (_firestore == null || uid == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    await _sub?.cancel();
    _sub = _firestore!
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs
                .map((d) => OrderModel.fromFirestore(d))
                .toList()
              ..sort(
                (a, b) => (b.createdAt ?? DateTime(0))
                    .compareTo(a.createdAt ?? DateTime(0)),
              );
            orders.assignAll(list);
            isLoading.value = false;
          },
          onError: (_) {
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
