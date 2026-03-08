class UserModel {
  UserModel({
    required this.uid,
    required this.role,
    this.restaurantId,
    this.restaurantName,
    this.displayName,
    this.email,
  });

  final String uid;
  /// 'customer' | 'seller' | 'driver'
  final String role;
  final String? restaurantId;
  final String? restaurantName;
  final String? displayName;
  final String? email;

  static UserModel fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      role: data['role'] as String? ?? 'customer',
      restaurantId: data['restaurantId'] as String?,
      restaurantName: data['restaurantName'] as String?,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
    );
  }
}
