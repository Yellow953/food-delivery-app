import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Handles sign-up page state and registration.
class SignupController extends GetxController {
  SignupController(this._authService);

  final AuthService _authService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  /// 'customer' | 'driver' | 'seller'
  final RxString selectedRole = 'customer'.obs;

  void selectRole(String role) => selectedRole.value = role;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
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
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your name';
      return;
    }
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
      final credential = await _authService.signUpWithEmailAndPassword(email, password);
      final uid = credential.user?.uid;
      if (uid != null) {
        await credential.user?.updateDisplayName(name);
        if (Firebase.apps.isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'role': selectedRole.value,
            'name': name,
            'phone': phone,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      if (selectedRole.value == 'seller') {
        Get.offAllNamed<void>(AppRoutes.sellerSetup);
      } else {
        Get.offAllNamed<void>(UserService.routeForRole(selectedRole.value));
      }
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
