import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

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
  }
}
