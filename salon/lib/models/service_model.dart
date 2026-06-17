class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationInMinutes;
  final String? imageUrl;
  final String category;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'description': description,
      'price': price,
      'durationInMinutes': durationInMinutes,
      'imageUrl': imageUrl,
      'category': category,
    };
    if (id.isNotEmpty) map['id'] = id;
    return map;
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationInMinutes: map['durationInMinutes'] ?? 0,
      imageUrl: map['imageUrl'],
      category: map['category'] ?? '',
    );
  }
}
