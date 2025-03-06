import 'cart.dart';
import 'product.dart';

class Order {
  final String id;
  final String userId;
  final double total;
  final List<CartItem> cartItems;
  final Map<String, dynamic>? selectedAddress;
  final String paymentMethod;
  final bool paid;
  final DateTime orderDate;
  final String orderStatus;
  final Map<String, dynamic>? cancellation;
  final Map<String, dynamic>? return_;
  final String shippingAddress;
  final List<Product> products;

  Order({
    required this.id,
    required this.userId,
    required this.total,
    required this.cartItems,
    required this.selectedAddress,
    required this.paymentMethod,
    required this.paid,
    required this.orderDate,
    required this.orderStatus,
    this.cancellation,
    this.return_,
    this.shippingAddress = '',
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      total: (json['total'] is String)
          ? double.tryParse(json['total']) ?? 0.0
          : (json['total'] ?? 0).toDouble(),
      cartItems: (json['cartItems'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      selectedAddress: json['selectedAddress'] as Map<String, dynamic>?,
      paymentMethod: json['paymentMethod'] ?? '',
      paid: json['paid'] ?? false,
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      orderStatus: json['orderStatus'] ?? 'Processing',
      cancellation: json['cancellation'] as Map<String, dynamic>?,
      return_: json['return'] as Map<String, dynamic>?,
      shippingAddress: json['shippingAddress'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'total': total,
        'cartItems': cartItems.map((item) => item.toJson()).toList(),
        'selectedAddress': selectedAddress,
        'paymentMethod': paymentMethod,
        'paid': paid,
        'orderDate': orderDate.toIso8601String(),
        'orderStatus': orderStatus,
        'cancellation': cancellation,
        'return': return_,
        'shippingAddress': shippingAddress,
        'products': products.map((item) => item.toJson()).toList(),
      };
}
