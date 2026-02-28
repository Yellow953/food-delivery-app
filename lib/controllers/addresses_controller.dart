import 'package:get/get.dart';

import '../models/address_model.dart';

class AddressesController extends GetxController {
  final RxList<AddressModel> addresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    addresses.add(AddressModel(
      id: '1',
      label: 'Home',
      addressLine: '123 Main St, Apt 4B, New York, NY 10001',
      isDefault: true,
    ));
  }

  void addAddress({
    required String label,
    required String addressLine,
    double? latitude,
    double? longitude,
  }) {
    final isFirst = addresses.isEmpty;
    addresses.add(AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      addressLine: addressLine,
      isDefault: isFirst,
      latitude: latitude,
      longitude: longitude,
    ));
  }

  void deleteAddress(String id) {
    final wasDefault =
        addresses.firstWhereOrNull((a) => a.id == id)?.isDefault ?? false;
    addresses.removeWhere((a) => a.id == id);
    if (wasDefault && addresses.isNotEmpty) {
      final updated = addresses.toList();
      updated[0] = updated[0].copyWith(isDefault: true);
      addresses.assignAll(updated);
    }
  }

  void setDefault(String id) {
    final updated =
        addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    addresses.assignAll(updated);
  }
}
