class StaffModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String position;
  final String specialization;
  final String? profilePhoto;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.position,
    required this.specialization,
    this.profilePhoto,
  });

  StaffModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? position,
    String? specialization,
    String? profilePhoto,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      position: position ?? this.position,
      specialization: specialization ?? this.specialization,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'position': position,
      'specialization': specialization,
      'profilePhoto': profilePhoto,
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map, String id) {
    return StaffModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      position: map['position'] ?? '',
      specialization: map['specialization'] ?? '',
      profilePhoto: map['profilePhoto'],
    );
  }
}
