import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.label,
    required this.iconName,
    required this.order,
  });

  final String id;
  final String label;
  final String iconName;
  final int order;

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      id: doc.id,
      label: data['label'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'restaurant',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
