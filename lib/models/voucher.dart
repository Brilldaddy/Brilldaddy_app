class Voucher {
  final String id;
  final String voucherName;
  final String details;
  final String productName;
  final String imageUrl;
  final int price;
  final int productPrice;
  final DateTime startTime;
  final DateTime endTime;
  final bool isExpired;

  Voucher({
    required this.id,
    required this.voucherName,
    required this.details,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.productPrice,
    required this.startTime,
    required this.endTime,
    required this.isExpired,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['_id'],
      voucherName: json['voucher_name'],
      details: json['details'],
      productName: json['product_name'],
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'],
      productPrice: json['productPrice'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isExpired: json['is_expired'],
    );
  }
}
