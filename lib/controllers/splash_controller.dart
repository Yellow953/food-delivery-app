import 'dart:async';

import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Controls splash screen logic and initial navigation.
class SplashController extends GetxController {
  SplashController(this._authService);

  final AuthService _authService;

  @override
  void onReady() {
    super.onReady();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (_authService.isLoggedIn) {
      final uid = _authService.currentUser.value!.uid;
      final userService = Get.find<UserService>();
      final role = await userService.fetchRoleForUid(uid);
      Get.offAllNamed<void>(UserService.routeForRole(role));
    } else {
      Get.offAllNamed<void>(AppRoutes.auth);
    }
  }
}
