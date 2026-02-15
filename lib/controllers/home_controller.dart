import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';

/// Main home / dashboard controller (placeholder for restaurant list, etc.).
class HomeController extends GetxController {
  HomeController(this._authService);

  final AuthService _authService;

  String? get userEmail => _authService.currentUser.value?.email;

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed<void>(AppRoutes.auth);
  }
}
