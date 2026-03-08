import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariantModel {
  ProductVariantModel({required this.name, required this.additionalPrice});

  final String name;
  final double additionalPrice;

  Map<String, dynamic> toMap() => {
        'name': name,
        'additionalPrice': additionalPrice,
      };

  static ProductVariantModel fromMap(Map<String, dynamic> m) =>
      ProductVariantModel(
        name: m['name'] as String? ?? '',
        additionalPrice: (m['additionalPrice'] as num?)?.toDouble() ?? 0,
      );
}

class SellerProductModel {
  SellerProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.imageUrls,
    required this.variants,
    required this.isAvailable,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final double basePrice;
  final List<String> imageUrls;
  final List<ProductVariantModel> variants;
  final bool isAvailable;
  final int order;

  /// Display price string, e.g. "$12.00"
  String get priceLabel => '\$${basePrice.toStringAsFixed(2)}';

  /// First image URL, or empty string
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  static SellerProductModel fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SellerProductModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? '',
      basePrice: (d['basePrice'] as num?)?.toDouble() ?? 0,
      imageUrls: (d['imageUrls'] as List?)?.cast<String>() ?? [],
      variants: (d['variants'] as List?)
              ?.map((e) =>
                  ProductVariantModel.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      isAvailable: d['isAvailable'] as bool? ?? true,
      order: (d['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'basePrice': basePrice,
        'imageUrls': imageUrls,
        'variants': variants.map((v) => v.toMap()).toList(),
        'isAvailable': isAvailable,
        'order': order,
      };
}
