import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/image_upload_service.dart';
import '../services/user_service.dart';

class SellerEditBusinessController extends GetxController {
  SellerEditBusinessController(this._authService);

  final AuthService _authService;

  late final TextEditingController nameController;
  late final TextEditingController cuisineController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;

  final RxBool isSaving = false.obs;
  final RxBool isUploadingLogo = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString logoUrl = ''.obs;

  UserService get _userService => Get.find<UserService>();

  @override
  void onInit() {
    super.onInit();
    final u = _userService.userModel.value;
    nameController = TextEditingController(text: u?.restaurantName ?? '');
    cuisineController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    _prefillFromFirestore();
  }

  Future<void> _prefillFromFirestore() async {
    final rid = _userService.restaurantId;
    if (rid == null || rid.isEmpty || Firebase.apps.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(rid)
          .get();
      if (doc.exists) {
        final d = doc.data()!;
        cuisineController.text = d['cuisine'] as String? ?? '';
        addressController.text = d['address'] as String? ?? '';
        phoneController.text = d['phone'] as String? ?? '';
        logoUrl.value = d['imageUrl'] as String? ?? '';
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    nameController.dispose();
    cuisineController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void clearError() => errorMessage.value = '';

  Future<void> pickLogo() async {
    isUploadingLogo.value = true;
    try {
      final rid = _userService.restaurantId ?? 'unknown';
      final url = await ImageUploadService.pickAndUpload(
        'restaurants/$rid/logo.jpg',
      );
      if (url != null) logoUrl.value = url;
    } finally {
      isUploadingLogo.value = false;
    }
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final cuisine = cuisineController.text.trim();
    final address = addressController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      errorMessage.value = 'Business name cannot be empty';
      return;
    }

    errorMessage.value = '';
    isSaving.value = true;
    try {
      final uid = _authService.currentUser.value?.uid;
      final rid = _userService.restaurantId;
      if (uid != null && Firebase.apps.isNotEmpty) {
        final db = FirebaseFirestore.instance;
        await db.collection('users').doc(uid).update({
          'restaurantName': name,
        });
        if (rid != null && rid.isNotEmpty) {
          await db.collection('restaurants').doc(rid).update({
            'name': name,
            'cuisine': cuisine,
            'address': address,
            'phone': phone,
            'imageUrl': logoUrl.value,
          });
        }
        // Update cached model
        final old = _userService.userModel.value;
        _userService.userModel.value = UserModel(
          uid: uid,
          role: old?.role ?? 'seller',
          restaurantId: old?.restaurantId,
          restaurantName: name,
          displayName: old?.displayName,
          email: old?.email,
        );
      }
      Get.back<void>();
      Get.snackbar(
        'Saved',
        'Business info updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      errorMessage.value = 'Could not save. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }
}
