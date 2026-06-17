class BeautyProductModel {
  final int id;
  final String brand;
  final String name;
  final String price;
  final String imageLink;
  final String description;
  final String category;
  final String productType;

  BeautyProductModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.imageLink,
    required this.description,
    required this.category,
    required this.productType,
  });

  factory BeautyProductModel.fromJson(Map<String, dynamic> json) {
    return BeautyProductModel(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? 'Generic',
      name: json['name'] ?? 'Product',
      price: json['price'] ?? '0.0',
      imageLink: json['image_link'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Beauty',
      productType: json['product_type'] ?? 'Item',
    );
  }
}
