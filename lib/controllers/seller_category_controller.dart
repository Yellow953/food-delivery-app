import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/seller_category_model.dart';
import '../services/user_service.dart';

class SellerCategoryController extends GetxController {
  SellerCategoryController(this._firestore);

  final FirebaseFirestore? _firestore;

  final RxList<SellerCategoryModel> categories = <SellerCategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  String? get _restaurantId => Get.find<UserService>().restaurantId;

  CollectionReference<Map<String, dynamic>>? get _ref {
    final rid = _restaurantId;
    if (_firestore == null || rid == null || rid.isEmpty) return null;
    return _firestore!
        .collection('restaurants')
        .doc(rid)
        .collection('categories');
  }

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  void _listen() {
    final ref = _ref;
    if (ref == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _sub = ref.orderBy('order').snapshots().listen(
      (snap) {
        categories.assignAll(
          snap.docs
              .map((d) => SellerCategoryModel.fromFirestore(d))
              .toList(),
        );
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );
  }

  Future<void> addCategory(String name) async {
    final ref = _ref;
    if (ref == null || name.trim().isEmpty) return;
    final nextOrder = categories.isEmpty ? 0 : categories.last.order + 1;
    await ref.add({'name': name.trim(), 'order': nextOrder});
  }

  Future<void> updateCategory(String id, String name) async {
    if (name.trim().isEmpty) return;
    await _ref?.doc(id).update({'name': name.trim()});
  }

  Future<void> deleteCategory(String id) async {
    await _ref?.doc(id).delete();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
