import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';

/// Handles sign-up page state and registration.
class SignupController extends GetxController {
  SignupController(this._authService);

  final AuthService _authService;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> signUp() async {
    if (!_authService.isFirebaseConfigured) {
      errorMessage.value =
          'Firebase is not configured. Run "flutterfire configure" (see FIREBASE_SETUP.md).';
      return;
    }
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Please enter a password';
      return;
    }
    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return;
    }
    if (password != confirm) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.signUpWithEmailAndPassword(email, password);
      Get.offAllNamed<void>(AppRoutes.home);
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
