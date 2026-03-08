import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

/// Fetches and caches the current user's role from Firestore users/{uid}.
class UserService extends GetxService {
  final Rxn<UserModel> userModel = Rxn<UserModel>();

  /// Fetches role for [uid] from Firestore. Falls back to 'customer' if no doc.
  Future<String> fetchRoleForUid(String uid) async {
    if (Firebase.apps.isEmpty) return 'customer';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final model = UserModel.fromMap(uid, doc.data()!);
        userModel.value = model;
        return model.role;
      }
    } catch (_) {}
    userModel.value = UserModel(uid: uid, role: 'customer');
    return 'customer';
  }

  /// Route string based on role.
  static String routeForRole(String role) {
    switch (role) {
      case 'seller':
        return '/seller';
      case 'driver':
        return '/driver';
      default:
        return '/home';
    }
  }

  String? get restaurantId => userModel.value?.restaurantId;
  String? get restaurantName => userModel.value?.restaurantName;
  String get role => userModel.value?.role ?? 'customer';
}
