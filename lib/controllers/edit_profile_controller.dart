import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class EditProfileController extends GetxController {
  EditProfileController(this._authService);

  final AuthService _authService;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  String get email => _authService.currentUser.value?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(
      text: _authService.currentUser.value?.displayName ?? '',
    );
    phoneController = TextEditingController();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final uid = _authService.currentUser.value?.uid;
    if (uid == null || Firebase.apps.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        phoneController.text = doc.data()?['phone'] as String? ?? '';
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
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
      final uid = _authService.currentUser.value?.uid;
      if (uid != null && Firebase.apps.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': name,
          'phone': phoneController.text.trim(),
        });
      }
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
