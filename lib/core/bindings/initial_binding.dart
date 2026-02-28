import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../../controllers/addresses_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../services/auth_service.dart';

/// Global bindings applied at app startup.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (Firebase.apps.isNotEmpty) {
      Get.put<AuthService>(FirebaseAuthService(), permanent: true);
    } else {
      Get.put<AuthService>(StubAuthService(), permanent: true);
    }
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<AddressesController>(AddressesController(), permanent: true);
  }
}
