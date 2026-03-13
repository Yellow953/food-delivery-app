import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/seller_product_model.dart';
import '../services/image_upload_service.dart';
import '../services/user_service.dart';
import 'seller_category_controller.dart';
import 'seller_store_controller.dart';

class SellerProductFormController extends GetxController {
  SellerProductFormController();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController basePriceController;

  final RxString selectedCategory = ''.obs;
  final RxList<String> imageUrls = <String>[].obs;
  final RxList<ProductVariantGroup> variantGroups =
      <ProductVariantGroup>[].obs;
  final RxBool isAvailable = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImages = false.obs;
  final RxString errorMessage = ''.obs;

  SellerCategoryController get categoryCtrl =>
      Get.find<SellerCategoryController>();

  SellerProductModel? _editingProduct;
  bool get isEditing => _editingProduct != null;

  String? get _restaurantId => Get.find<UserService>().restaurantId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is SellerProductModel) _editingProduct = args;

    final p = _editingProduct;
    titleController = TextEditingController(text: p?.title ?? '');
    descriptionController = TextEditingController(text: p?.description ?? '');
    basePriceController = TextEditingController(
      text: p != null && p.basePrice > 0 ? p.basePrice.toStringAsFixed(2) : '',
    );
    if (p != null) {
      selectedCategory.value = p.category;
      imageUrls.assignAll(p.imageUrls);
      variantGroups.assignAll(p.variantGroups);
      isAvailable.value = p.isAvailable;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    basePriceController.dispose();
    super.onClose();
  }

  void clearError() => errorMessage.value = '';

  // ─── Images ──────────────────────────────────────────────────────────────

  Future<void> pickImages() async {
    final rid = _restaurantId ?? 'unknown';
    isUploadingImages.value = true;
    try {
      final urls = await ImageUploadService.pickMultipleAndUpload(
          'restaurants/$rid/products');
      if (urls.isNotEmpty) imageUrls.addAll(urls);
    } finally {
      isUploadingImages.value = false;
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < imageUrls.length) imageUrls.removeAt(index);
  }

  void reorderImage(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = imageUrls.removeAt(oldIndex);
    imageUrls.insert(newIndex, item);
  }

  // ─── Variant groups ───────────────────────────────────────────────────────

  void addVariantGroup(String name, String type) {
    if (name.trim().isEmpty) return;
    variantGroups.add(
        ProductVariantGroup(name: name.trim(), type: type, options: []));
  }

  void removeVariantGroup(int index) {
    if (index >= 0 && index < variantGroups.length) {
      variantGroups.removeAt(index);
    }
  }

  void updateVariantGroup(int index, String name, String type) {
    if (index < 0 || index >= variantGroups.length) return;
    variantGroups[index] = variantGroups[index].copyWith(
      name: name.trim(),
      type: type,
    );
  }

  void setGroupType(int index, String type) {
    if (index < 0 || index >= variantGroups.length) return;
    variantGroups[index] = variantGroups[index].copyWith(type: type);
  }

  // ─── Options within a group ───────────────────────────────────────────────

  void addOption(int groupIndex, String name, double price) {
    if (groupIndex < 0 || groupIndex >= variantGroups.length) return;
    if (name.trim().isEmpty) return;
    final group = variantGroups[groupIndex];
    variantGroups[groupIndex] = group.copyWith(options: [
      ...group.options,
      ProductVariantOption(name: name.trim(), additionalPrice: price),
    ]);
  }

  void removeOption(int groupIndex, int optionIndex) {
    if (groupIndex < 0 || groupIndex >= variantGroups.length) return;
    final group = variantGroups[groupIndex];
    final newOpts = [...group.options]..removeAt(optionIndex);
    variantGroups[groupIndex] = group.copyWith(options: newOpts);
  }

  void updateOption(
      int groupIndex, int optionIndex, String name, double price) {
    if (groupIndex < 0 || groupIndex >= variantGroups.length) return;
    final group = variantGroups[groupIndex];
    final newOpts = [...group.options];
    newOpts[optionIndex] =
        ProductVariantOption(name: name.trim(), additionalPrice: price);
    variantGroups[groupIndex] = group.copyWith(options: newOpts);
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> save() async {
    final title = titleController.text.trim();
    final priceRaw = basePriceController.text.trim();

    if (title.isEmpty) {
      errorMessage.value = 'Please enter a product name';
      return;
    }
    if (priceRaw.isEmpty) {
      errorMessage.value = 'Please enter a base price';
      return;
    }
    final basePrice = double.tryParse(priceRaw);
    if (basePrice == null || basePrice < 0) {
      errorMessage.value = 'Please enter a valid price';
      return;
    }

    errorMessage.value = '';
    isSaving.value = true;
    try {
      final storeCtrl = Get.find<SellerStoreController>();
      final data = <String, dynamic>{
        'title': title,
        'description': descriptionController.text.trim(),
        'category': selectedCategory.value,
        'basePrice': basePrice,
        'imageUrls': imageUrls.toList(),
        'variants': variantGroups.map((g) => g.toMap()).toList(),
        'isAvailable': isAvailable.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        await storeCtrl.updateProduct(_editingProduct!.id, data);
      } else {
        await storeCtrl.addProduct(data);
      }
      Get.back<void>();
      Get.snackbar(
        isEditing ? 'Updated' : 'Added',
        isEditing ? 'Product updated.' : 'Product added to your store.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }
}
