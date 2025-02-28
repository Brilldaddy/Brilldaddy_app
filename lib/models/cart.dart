import 'product.dart';

class Cart {
  final String userId;
  final List<CartItem> items;

  Cart({required this.userId, required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}


class CartItem {
  final Product product; 
  // Store product object
  final int quantity;
  final double price;
  final bool walletDiscountApplied;
  final double walletDiscountAmount;
  final String? status;
final String? size;

  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.walletDiscountApplied,
    required this.walletDiscountAmount,
    required this.status,
     this.size
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['productId']), // Convert to Product object
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      walletDiscountApplied: json['walletDiscountApplied'],
      walletDiscountAmount: json['walletDiscountAmount'].toDouble(),
      status: json['status'],
      size: json['size']
    );
  }
}
