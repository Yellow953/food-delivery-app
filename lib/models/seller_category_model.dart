import 'package:cloud_firestore/cloud_firestore.dart';

class SellerCategoryModel {
  SellerCategoryModel({
    required this.id,
    required this.name,
    required this.order,
  });

  final String id;
  final String name;
  final int order;

  static SellerCategoryModel fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SellerCategoryModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      order: (d['order'] as num?)?.toInt() ?? 0,
    );
  }
}
