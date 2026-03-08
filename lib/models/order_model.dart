import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  OrderModel({
    required this.id,
    required this.deliveryAddress,
    required this.status,
    required this.total,
    required this.itemCount,
    required this.paymentMethod,
    this.restaurantId,
    this.restaurantName,
    this.driverId,
    this.customerName,
    this.items,
    this.createdAt,
  });

  final String id;
  final String deliveryAddress;
  final String status;
  final double total;
  final int itemCount;
  final String paymentMethod;
  final String? restaurantId;
  final String? restaurantName;
  final String? driverId;
  final String? customerName;
  final List<Map<String, dynamic>>? items;
  final DateTime? createdAt;

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Order received';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'ready_for_pickup':
        return 'Ready for pickup';
      case 'on_the_way':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Rejected';
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
      restaurantId: data['restaurantId'] as String?,
      restaurantName: data['restaurantName'] as String?,
      driverId: data['driverId'] as String?,
      customerName: data['customerName'] as String?,
      items: (data['items'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
