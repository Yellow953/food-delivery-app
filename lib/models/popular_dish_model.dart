import 'package:cloud_firestore/cloud_firestore.dart';

class PopularDishModel {
  PopularDishModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    required this.order,
  });

  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;
  final int order;

  factory PopularDishModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PopularDishModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      price: data['price'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
