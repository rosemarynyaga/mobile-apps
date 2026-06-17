class PromotionModel {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime expiryDate;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.expiryDate,
  });

  PromotionModel copyWith({
    String? id,
    String? title,
    String? description,
    double? discountPercentage,
    DateTime? expiryDate,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map, String id) {
    return PromotionModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercentage: (map['discountPercentage'] ?? 0).toDouble(),
      expiryDate: DateTime.parse(map['expiryDate'].toString()),
    );
  }
}
