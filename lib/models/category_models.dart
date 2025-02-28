import "product.dart";

class Category {
  final String id;
  final String name;
  final String description;
  final String? parentCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product product;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.parentCategory,
    required this.createdAt,
    required this.updatedAt,
    required this.product
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      parentCategory: json['parentCategory'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      product: Product.fromJson(json['product']), 
    );
  }
}
