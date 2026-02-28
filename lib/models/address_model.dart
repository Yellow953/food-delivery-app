class AddressModel {
  AddressModel({
    required this.id,
    required this.label,
    required this.addressLine,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String label;       // e.g. 'Home', 'Work', 'Other'
  final String addressLine;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  AddressModel copyWith({
    String? label,
    String? addressLine,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return AddressModel(
      id: id,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
