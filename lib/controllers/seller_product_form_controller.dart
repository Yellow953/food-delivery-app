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
  final RxList<ProductVariantModel> variants = <ProductVariantModel>[].obs;
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
      text: p != null && p.basePrice > 0
          ? p.basePrice.toStringAsFixed(2)
          : '',
    );
    if (p != null) {
      selectedCategory.value = p.category;
      imageUrls.assignAll(p.imageUrls);
      variants.assignAll(p.variants);
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
        'restaurants/$rid/products',
      );
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

  // ─── Variants ────────────────────────────────────────────────────────────

  void addVariant(String name, double additionalPrice) {
    if (name.trim().isEmpty) return;
    variants.add(
        ProductVariantModel(name: name.trim(), additionalPrice: additionalPrice));
  }

  void removeVariant(int index) {
    if (index >= 0 && index < variants.length) variants.removeAt(index);
  }

  void updateVariant(int index, String name, double additionalPrice) {
    if (index < 0 || index >= variants.length) return;
    variants[index] =
        ProductVariantModel(name: name.trim(), additionalPrice: additionalPrice);
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
        'variants': variants.map((v) => v.toMap()).toList(),
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
