import 'product.dart';

class WishlistItem {
  final Product product;

  WishlistItem({required this.product});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // Assuming the backend returns a nested product object under "productId"
    return WishlistItem(
      product: Product.fromJson(json['productId']),
    );
  }
}
