import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

/// Handles forgot-password page and send reset email.
class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authService);

  final AuthService _authService;

  final TextEditingController emailController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool emailSent = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetEmail() async {
    if (!_authService.isFirebaseConfigured) {
      errorMessage.value =
          'Firebase is not configured. Run "flutterfire configure" (see FIREBASE_SETUP.md).';
      return;
    }
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return;
    }

    errorMessage.value = '';
    emailSent.value = false;
    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(email);
      emailSent.value = true;
    } on Exception catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}
