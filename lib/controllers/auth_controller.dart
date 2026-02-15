import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';

/// Handles auth screen state and sign-in / sign-up.
class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  bool get isLoggedIn => _authService.isLoggedIn;

  Future<void> signIn(String email, String password) async {
    if (!_authService.isFirebaseConfigured) {
      errorMessage.value =
          'Firebase is not configured. Run "flutterfire configure" (see FIREBASE_SETUP.md).';
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter email and password';
      return;
    }
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      Get.offAllNamed<void>(AppRoutes.home);
    } on Exception catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    if (!_authService.isFirebaseConfigured) {
      errorMessage.value =
          'Firebase is not configured. Run "flutterfire configure" (see FIREBASE_SETUP.md).';
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter email and password';
      return;
    }
    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
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

  Future<void> signInWithGoogle() async {
    if (!_authService.isFirebaseConfigured) {
      errorMessage.value =
          'Firebase is not configured. Run "flutterfire configure" (see FIREBASE_SETUP.md).';
      return;
    }
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await _authService.signInWithGoogle();
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
