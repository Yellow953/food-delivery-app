import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVariantOption {
  ProductVariantOption({required this.name, required this.additionalPrice});

  final String name;
  final double additionalPrice;

  String get priceLabel =>
      additionalPrice == 0 ? 'Included' : '+\$${additionalPrice.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() => {
        'name': name,
        'additionalPrice': additionalPrice,
      };

  static ProductVariantOption fromMap(Map<String, dynamic> m) =>
      ProductVariantOption(
        name: m['name'] as String? ?? '',
        additionalPrice: (m['additionalPrice'] as num?)?.toDouble() ?? 0,
      );
}

class ProductVariantGroup {
  ProductVariantGroup({
    required this.name,
    required this.type,
    required this.options,
  });

  final String name;

  /// 'single' = pick exactly one (radio), 'multiple' = pick many (checkboxes)
  final String type;
  final List<ProductVariantOption> options;

  bool get isSingle => type == 'single';
  String get typeLabel => isSingle ? 'Single choice' : 'Multiple choice';

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'options': options.map((o) => o.toMap()).toList(),
      };

  static ProductVariantGroup fromMap(Map<String, dynamic> m) =>
      ProductVariantGroup(
        name: m['name'] as String? ?? '',
        type: m['type'] as String? ?? 'single',
        options: (m['options'] as List?)
                ?.map((e) => ProductVariantOption.fromMap(
                    Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );

  ProductVariantGroup copyWith({
    String? name,
    String? type,
    List<ProductVariantOption>? options,
  }) =>
      ProductVariantGroup(
        name: name ?? this.name,
        type: type ?? this.type,
        options: options ?? this.options,
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
    required this.variantGroups,
    required this.isAvailable,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final double basePrice;
  final List<String> imageUrls;
  final List<ProductVariantGroup> variantGroups;
  final bool isAvailable;
  final int order;

  String get priceLabel => '\$${basePrice.toStringAsFixed(2)}';
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  static SellerProductModel fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawVariants = d['variants'] as List?;

    List<ProductVariantGroup> groups = [];
    if (rawVariants != null && rawVariants.isNotEmpty) {
      final first = rawVariants.first as Map?;
      if (first != null && first.containsKey('options')) {
        // New format: list of variant groups
        groups = rawVariants
            .map((e) => ProductVariantGroup.fromMap(
                Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        // Legacy format: flat list of {name, additionalPrice} → wrap in one group
        groups = [
          ProductVariantGroup(
            name: 'Options',
            type: 'single',
            options: rawVariants
                .map((e) => ProductVariantOption.fromMap(
                    Map<String, dynamic>.from(e as Map)))
                .toList(),
          ),
        ];
      }
    }

    return SellerProductModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: d['category'] as String? ?? '',
      basePrice: (d['basePrice'] as num?)?.toDouble() ?? 0,
      imageUrls: (d['imageUrls'] as List?)?.cast<String>() ?? [],
      variantGroups: groups,
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
        'variants': variantGroups.map((g) => g.toMap()).toList(),
        'isAvailable': isAvailable,
        'order': order,
      };
}
