import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/seller_product_model.dart';
import '../services/user_service.dart';

class SellerStoreController extends GetxController {
  SellerStoreController(this._firestore);

  final FirebaseFirestore? _firestore;

  final RxList<SellerProductModel> products = <SellerProductModel>[].obs;
  final RxBool isLoading = true.obs;

  /// null = show all, otherwise filter by category name
  final Rxn<String> selectedCategory = Rxn<String>();

  List<SellerProductModel> get filteredProducts {
    final cat = selectedCategory.value;
    if (cat == null) return products;
    return products.where((p) => p.category == cat).toList();
  }

  void selectCategory(String? category) => selectedCategory.value = category;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  String? get _restaurantId => Get.find<UserService>().restaurantId;

  CollectionReference<Map<String, dynamic>>? get _productsRef {
    final rid = _restaurantId;
    if (_firestore == null || rid == null || rid.isEmpty) return null;
    return _firestore!.collection('restaurants').doc(rid).collection('products');
  }

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  void _listen() {
    final ref = _productsRef;
    if (ref == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _sub = ref.orderBy('order').snapshots().listen(
      (snap) {
        products.assignAll(
          snap.docs.map((d) => SellerProductModel.fromFirestore(d)).toList(),
        );
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );
  }

  Future<void> toggleAvailability(SellerProductModel product) async {
    await _productsRef?.doc(product.id).update({
      'isAvailable': !product.isAvailable,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _productsRef?.doc(id).delete();
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    final ref = _productsRef;
    if (ref == null) return;
    final nextOrder = products.isEmpty ? 0 : products.last.order + 1;
    await ref.add({...data, 'order': nextOrder});
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _productsRef?.doc(id).update(data);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
