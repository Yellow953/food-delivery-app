import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  OrderModel({
    required this.id,
    required this.deliveryAddress,
    required this.status,
    required this.total,
    required this.itemCount,
    required this.paymentMethod,
    this.createdAt,
  });

  final String id;
  final String deliveryAddress;
  final String status;
  final double total;
  final int itemCount;
  final String paymentMethod;
  final DateTime? createdAt;

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Order received';
      case 'preparing':
        return 'Preparing';
      case 'on_the_way':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  static OrderModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrderModel(
      id: doc.id,
      deliveryAddress: data['deliveryAddress'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      itemCount: (data['items'] as List?)?.length ?? 0,
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
