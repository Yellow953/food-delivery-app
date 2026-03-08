import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/image_upload_service.dart';
import '../services/user_service.dart';

class SellerSetupController extends GetxController {
  SellerSetupController(this._authService);

  final AuthService _authService;

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController businessPhoneController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isUploadingLogo = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString logoUrl = ''.obs;

  @override
  void onClose() {
    businessNameController.dispose();
    businessAddressController.dispose();
    businessPhoneController.dispose();
    businessTypeController.dispose();
    super.onClose();
  }

  void clearError() => errorMessage.value = '';

  Future<void> pickLogo() async {
    isUploadingLogo.value = true;
    try {
      final uid = _authService.currentUser.value?.uid ?? 'temp';
      final url = await ImageUploadService.pickAndUpload(
        'restaurants/temp_$uid/logo.jpg',
      );
      if (url != null) logoUrl.value = url;
    } finally {
      isUploadingLogo.value = false;
    }
  }

  Future<void> submit() async {
    final name = businessNameController.text.trim();
    final address = businessAddressController.text.trim();
    final phone = businessPhoneController.text.trim();
    final type = businessTypeController.text.trim();

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your business name';
      return;
    }
    if (address.isEmpty) {
      errorMessage.value = 'Please enter your business address';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;
    try {
      final uid = _authService.currentUser.value?.uid;
      if (uid != null && Firebase.apps.isNotEmpty) {
        final db = FirebaseFirestore.instance;

        final restaurantRef = await db.collection('restaurants').add({
          'name': name,
          'address': address,
          'phone': phone,
          'cuisine': type.isNotEmpty ? type : 'Restaurant',
          'rating': '5.0',
          'imageUrl': logoUrl.value,
          'order': 999,
          'ownerId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await db.collection('users').doc(uid).update({
          'restaurantId': restaurantRef.id,
          'restaurantName': name,
        });

        final userService = Get.find<UserService>();
        userService.userModel.value = UserModel(
          uid: uid,
          role: 'seller',
          restaurantId: restaurantRef.id,
          restaurantName: name,
        );
      }

      Get.offAllNamed<void>(AppRoutes.seller);
    } on Exception catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
