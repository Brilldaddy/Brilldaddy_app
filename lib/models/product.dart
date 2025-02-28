class Product {
  final String id;
  final String name;
  final String description;
  final double productPrice;
  final double salePrice;
  final String category;
  final String brand;
  final bool isListed;
  late final int quantity;
  final double discount;
  final String color;
  final List<String> imageIds;
  List<String>? imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? sizes; // Optional sizes (strings)
  final List<dynamic>? ratings; // You can create a proper Rating model if needed.
  final double averageRating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.productPrice,
    required this.salePrice,
    required this.category,
    required this.brand,
    required this.isListed,
    required this.quantity,
    required this.discount,
    required this.color,
    required this.imageIds,
    this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    this.sizes,
    this.ratings,
    required this.averageRating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Convert sizes: if they are provided as objects with a "size" key, extract that; if they're strings, use them directly.
    List<String>? parsedSizes;
    if (json['sizes'] != null) {
      parsedSizes = (json['sizes'] as List<dynamic>).map((sizeData) {
        if (sizeData is String) return sizeData;
        if (sizeData is Map<String, dynamic> && sizeData.containsKey('size')) {
          return sizeData['size'] as String;
        }
        return null;
      }).whereType<String>().toList();
    }

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      productPrice: (json['productPrice'] ?? 0).toDouble(),
      salePrice: (json['salePrice'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      isListed: json['isListed'] ?? false,
      quantity: json['quantity'] ?? 0,
      discount: (json['discount'] ?? 0).toDouble(),
      color: json['color'] ?? '',
      imageIds: json['images'] != null
          ? List<String>.from(json['images'])
          : <String>[],
      imageUrls: null, // You can assign this later when images are fetched
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      sizes: parsedSizes,
      ratings: json['ratings'] != null ? List<dynamic>.from(json['ratings']) : null,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'productPrice': productPrice,
      'salePrice': salePrice,
      'category': category,
      'brand': brand,
      'isListed': isListed,
      'quantity': quantity,
      'discount': discount,
      'color': color,
      'imageUrl': imageUrls != null && imageUrls!.isNotEmpty ? imageUrls!.first : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sizes': sizes ?? [],
      'ratings': ratings ?? [],
      'averageRating': averageRating,
    };
  }
}
