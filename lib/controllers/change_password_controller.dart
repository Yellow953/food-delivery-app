import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController(this._authService);

  final AuthService _authService;

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isSaving = false.obs;
  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxString errorMessage = ''.obs;

  void clearError() => errorMessage.value = '';

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    final current = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (current.isEmpty) {
      errorMessage.value = 'Please enter your current password';
      return;
    }
    if (newPass.length < 6) {
      errorMessage.value = 'New password must be at least 6 characters';
      return;
    }
    if (newPass != confirm) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    errorMessage.value = '';
    isSaving.value = true;
    try {
      final user = _authService.currentUser.value;
      if (user == null || user.email == null) {
        errorMessage.value = 'No authenticated user found';
        return;
      }
      // Re-authenticate then update
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);
      Get.back<void>();
      Get.snackbar(
        'Done',
        'Password changed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Could not change password.';
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }
}
