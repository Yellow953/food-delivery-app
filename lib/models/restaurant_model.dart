import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.imageUrl,
    required this.order,
    this.address,
    this.phone,
  });

  final String id;
  final String name;
  final String cuisine;
  final String rating;
  final String imageUrl;
  final int order;
  final String? address;
  final String? phone;

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RestaurantModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      cuisine: data['cuisine'] as String? ?? '',
      rating: data['rating'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
      address: data['address'] as String?,
      phone: data['phone'] as String?,
    );
  }
}
