import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    required this.order,
  });

  final String id;
  final String imageUrl;
  final String? title;
  final int order;

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      title: data['title'] as String?,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
