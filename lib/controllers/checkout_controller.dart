import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../services/auth_service.dart';
import 'addresses_controller.dart';
import 'cart_controller.dart';

class CheckoutController extends GetxController {
  CheckoutController(this._authService, this._firestore);

  final AuthService _authService;
  final FirebaseFirestore? _firestore;

  CartController get _cart => Get.find<CartController>();
  AddressesController get _addressesCtrl => Get.find<AddressesController>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  final RxString paymentMethod = 'cash'.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxBool orderPlaced = false.obs;
  final RxString orderId = ''.obs;

  final RxString nameError = ''.obs;
  final RxString addressError = ''.obs;

  // ID of the selected saved address ('manual' means typed manually)
  final RxString selectedAddressId = ''.obs;

  List<AddressModel> get savedAddresses => _addressesCtrl.addresses;

  List<CartItem> get items => _cart.items;
  double get subtotal => _cart.subtotal;
  double get deliveryFee => CartController.deliveryFee;
  double get total => _cart.total;
  bool get isEmpty => _cart.items.isEmpty;

  void incrementItem(int index) => _cart.increment(index);
  void decrementItem(int index) => _cart.decrement(index);

  @override
  void onInit() {
    super.onInit();
    // Pre-fill from Firebase Auth profile
    final user = _authService.currentUser.value;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
    }
    // Pre-select default saved address
    final defaultAddr =
        _addressesCtrl.addresses.firstWhereOrNull((a) => a.isDefault);
    if (defaultAddr != null) {
      selectedAddressId.value = defaultAddr.id;
      addressController.text = defaultAddr.addressLine;
    }
  }

  void selectAddress(AddressModel addr) {
    selectedAddressId.value = addr.id;
    addressController.text = addr.addressLine;
    if (addressError.value.isNotEmpty) addressError.value = '';
  }

  void selectManualEntry() {
    selectedAddressId.value = 'manual';
    addressController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> placeOrder() async {
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    bool hasError = false;

    if (name.isEmpty) {
      nameError.value = 'Please enter your name.';
      hasError = true;
    } else {
      nameError.value = '';
    }

    if (address.isEmpty) {
      addressError.value = 'Please enter a delivery address.';
      hasError = true;
    } else {
      addressError.value = '';
    }

    if (hasError || isEmpty) return;

    isPlacingOrder.value = true;
    try {
      final itemData = items
          .map(
            (item) => {
              'dishTitle': item.dish.title,
              'dishImageUrl': item.dish.imageUrl,
              'sizeName': item.sizeName,
              'addons': item.addons,
              'price': item.price,
              'quantity': item.quantity,
            },
          )
          .toList();

      if (_firestore != null) {
        final docRef = await _firestore!.collection('orders').add({
          'userId': _authService.currentUser.value?.uid ?? '',
          'customerName': name,
          'customerPhone': phoneController.text.trim(),
          'customerEmail': emailController.text.trim(),
          'items': itemData,
          'deliveryAddress': address,
          'paymentMethod': paymentMethod.value,
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'total': total,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        orderId.value = '#${docRef.id.substring(0, 6).toUpperCase()}';
      } else {
        // Simulate when Firebase is not configured
        await Future<void>.delayed(const Duration(milliseconds: 800));
        orderId.value =
            '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }

      _cart.clear();
      orderPlaced.value = true;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not place order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
