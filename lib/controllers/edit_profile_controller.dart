import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._authService);

  final AuthService _authService;

  late final TextEditingController nameController;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  String get email => _authService.currentUser.value?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(
      text: _authService.currentUser.value?.displayName ?? '',
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      error.value = 'Display name cannot be empty.';
      return;
    }
    error.value = '';
    isSaving.value = true;
    try {
      await _authService.currentUser.value?.updateDisplayName(name);
      Get.back<void>();
      Get.snackbar(
        'Saved',
        'Profile updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      error.value = 'Could not update profile. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }
}
