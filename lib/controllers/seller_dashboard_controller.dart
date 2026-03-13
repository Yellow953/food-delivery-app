import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../services/user_service.dart';

class DayStats {
  DayStats({required this.day, required this.count, required this.revenue});
  final DateTime day;
  final int count;
  final double revenue;
}

class SellerDashboardController extends GetxController {
  SellerDashboardController(this._firestore);

  final FirebaseFirestore? _firestore;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  static const _activeStatuses = [
    'pending', 'accepted', 'preparing', 'ready_for_pickup'
  ];

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
    Query<Map<String, dynamic>> query = db.collection('orders');
    if (rid != null && rid.isNotEmpty) {
      query = query.where('restaurantId', isEqualTo: rid);
    }

    _sub = query
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .listen(
          (snap) {
            orders.assignAll(
                snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
            isLoading.value = false;
          },
          onError: (_) => isLoading.value = false,
        );
  }

  // ─── Today ───────────────────────────────────────────────────────────────

  bool _isToday(DateTime? dt) {
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  bool _isSameDay(DateTime? dt, DateTime target) {
    if (dt == null) return false;
    return dt.year == target.year &&
        dt.month == target.month &&
        dt.day == target.day;
  }

  int get todayOrderCount =>
      orders.where((o) => _isToday(o.createdAt)).length;

  double get todayRevenue => orders
      .where((o) => _isToday(o.createdAt))
      .fold(0.0, (s, o) => s + o.total);

  int get activeOrderCount =>
      orders.where((o) => _activeStatuses.contains(o.status)).length;

  int get totalOrderCount => orders.length;

  double get totalRevenue =>
      orders.fold(0.0, (s, o) => s + o.total);

  // ─── Weekly trend (last 7 days) ──────────────────────────────────────────

  List<DayStats> get weeklyStats {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));
      final dayOrders = orders.where((o) => _isSameDay(o.createdAt, day));
      return DayStats(
        day: day,
        count: dayOrders.length,
        revenue: dayOrders.fold(0.0, (s, o) => s + o.total),
      );
    });
  }

  double get weeklyMaxCount {
    final max = weeklyStats.fold(0, (m, s) => s.count > m ? s.count : m);
    return max == 0 ? 1 : max.toDouble();
  }

  // ─── Status distribution ─────────────────────────────────────────────────

  static const statusOrder = [
    'pending', 'accepted', 'preparing', 'ready_for_pickup',
    'on_the_way', 'delivered', 'rejected',
  ];

  Map<String, int> get statusCounts {
    final map = <String, int>{};
    for (final o in orders) {
      map[o.status] = (map[o.status] ?? 0) + 1;
    }
    return map;
  }

  // ─── Recent orders ────────────────────────────────────────────────────────

  List<OrderModel> get recentOrders => orders.take(5).toList();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
