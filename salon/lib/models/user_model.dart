class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer', 'staff', 'admin'
  final String? profileImage;
  final String? address;
  final String? gender;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.address,
    this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'address': address,
      'gender': gender,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      profileImage: map['profileImage'],
      address: map['address'],
      gender: map['gender'],
    );
  }
}
