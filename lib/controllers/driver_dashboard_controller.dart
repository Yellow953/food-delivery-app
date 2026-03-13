import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/order_model.dart';
import '../services/auth_service.dart';

class DriverDayStats {
  DriverDayStats({
    required this.day,
    required this.count,
    required this.earnings,
  });
  final DateTime day;
  final int count;
  final double earnings;
}

class DriverDashboardController extends GetxController {
  DriverDashboardController(this._authService, this._firestore);

  final AuthService _authService;
  final FirebaseFirestore? _firestore;

  /// Driver earns 15% of each order total as delivery fee.
  static const double _earningsRate = 0.15;

  final RxList<OrderModel> deliveries = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  String? get _uid => _authService.currentUser.value?.uid;

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  void _listen() {
    final db = _firestore;
    final uid = _uid;
    if (db == null || uid == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _sub = db
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('driverId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .listen(
          (snap) {
            deliveries.assignAll(
                snap.docs.map((d) => OrderModel.fromFirestore(d)).toList());
            isLoading.value = false;
          },
          onError: (_) => isLoading.value = false,
        );
  }

  double _fee(OrderModel o) => o.total * _earningsRate;

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

  // ─── Summary stats ──────────────────────────────────────────────────────────

  int get todayDeliveryCount =>
      deliveries.where((o) => _isToday(o.createdAt)).length;

  double get todayEarnings => deliveries
      .where((o) => _isToday(o.createdAt))
      .fold(0.0, (s, o) => s + _fee(o));

  int get totalDeliveryCount => deliveries.length;

  double get totalEarnings => deliveries.fold(0.0, (s, o) => s + _fee(o));

  // ─── Weekly trend (last 7 days) ─────────────────────────────────────────────

  List<DriverDayStats> get weeklyStats {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final dayOrders = deliveries.where((o) => _isSameDay(o.createdAt, day));
      return DriverDayStats(
        day: day,
        count: dayOrders.length,
        earnings: dayOrders.fold(0.0, (s, o) => s + _fee(o)),
      );
    });
  }

  double get weeklyMaxCount {
    final max = weeklyStats.fold(0, (m, s) => s.count > m ? s.count : m);
    return max == 0 ? 1 : max.toDouble();
  }

  // ─── Settlement periods ──────────────────────────────────────────────────────

  double get currentWeekEarnings {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return deliveries
        .where((o) =>
            o.createdAt != null && !o.createdAt!.isBefore(weekStart))
        .fold(0.0, (s, o) => s + _fee(o));
  }

  double get lastWeekEarnings {
    final now = DateTime.now();
    final thisWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    return deliveries
        .where((o) =>
            o.createdAt != null &&
            !o.createdAt!.isBefore(lastWeekStart) &&
            o.createdAt!.isBefore(thisWeekStart))
        .fold(0.0, (s, o) => s + _fee(o));
  }

  // ─── Recent deliveries ──────────────────────────────────────────────────────

  List<OrderModel> get recentDeliveries => deliveries.take(5).toList();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
