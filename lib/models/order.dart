// order.dart
import 'product.dart';

class BankDetails {
  final String accountNumber;
  final String ifscCode;
  final String branch;
  final String accountHolderName;

  BankDetails({
    required this.accountNumber,
    required this.ifscCode,
    required this.branch,
    required this.accountHolderName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branch: json['branch'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
        'branch': branch,
        'accountHolderName': accountHolderName,
      };
}

class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final String? size;
  final String status;
  final String? refundAmountStatus;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    this.size,
    required this.status,
    this.refundAmountStatus,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['productId'] as Map<String, dynamic>? ?? {};

    // Safely handle images as a list
    final dynamic rawImages = productData['images'];
    final List<dynamic> images = rawImages is List ? rawImages : [];

    int quantity;
    if (json['quantity'] is String) {
      quantity = int.tryParse(json['quantity']) ?? 0;
    } else {
      quantity = json['quantity'] ?? 0;
    }

    double price;
    if (json['price'] is String) {
      price = double.tryParse(json['price']) ?? 0.0;
    } else {
      price = (json['price'] ?? 0).toDouble();
    }

    return CartItem(
      productId: productData['_id'] ?? '',
      productName: productData['name'] ?? '',
      productImage: images.isNotEmpty ? images[0].toString() : '',
      quantity: quantity,
      price: price,
      size: json['size'],
      status: json['status'] ?? 'Processing',
      refundAmountStatus: json['refundAmountStatus'],
    );
  }
}

class Order {
  final String id;
  final String userId;
  final double total;
  final List<CartItem> cartItems;
  final Map<String, dynamic> selectedAddress;
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
    List<CartItem> cartItems = [];
    if (json['cartItems'] != null) {
      cartItems = (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<Product> products = [];
    if (json['products'] != null) {
      products = (json['products'] as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    double total;
    if (json['total'] is String) {
      total = double.tryParse(json['total']) ?? 0.0;
    } else {
      total = (json['total'] ?? 0).toDouble();
    }

    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      total: total,
      cartItems: cartItems,
      selectedAddress: json['selectedAddressId'] ?? {},
      paymentMethod: json['paymentMethod'] ?? '',
      paid: json['paid'] ?? false,
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toString()),
      orderStatus: json['orderStatus'] ?? 'Processing',
      cancellation: json['cancellation'],
      return_: json['return'],
      products: products,
    );
  }
}
