import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/bindings/initial_binding.dart';
import 'core/platform_env.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      // No Dart options (e.g. stub firebase_options). Use native config if present.
      try {
        await Firebase.initializeApp();
      } catch (_) {
        // No GoogleService-Info.plist / google-services.json or invalid config
      }
    }
  }

  // Seed Firestore on every startup when Firebase is available (idempotent).
  // Use SEED_FIRESTORE=force to clear and re-seed.
  if (Firebase.apps.isNotEmpty) {
    final service = FirestoreSeedService(FirebaseFirestore.instance);
    final seedFlag = environment('SEED_FIRESTORE');
    if (seedFlag == 'force') {
      await service.forceSeed();
      debugPrint('Firestore force-seeded: data cleared and re-seeded.');
    } else {
      await service.seedIfNeeded();
    }
  }

  // For Google Sign-In: set Web client ID from Firebase Console (Web app):
  // AuthService.googleSignInWebClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
