import 'dart:convert';

class Winner {
  final String id;
  final String prize;
  final String bidId;
  final String username;
  final String state;
  final String productName;

  Winner({
    required this.id,
    required this.prize,
    required this.bidId,
    required this.username,
    required this.state,
    required this.productName,
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      id: json['_id'] ?? '',
      prize: json['winningBidId']?['bidAmount']?.toString() ?? '',
      bidId: json['winningBidId']?['_id'] ?? '',
      username: json['userId']?['username'] ?? '',
      state: json['userId']?['currentAddress']?['state'] ?? '',
      productName: json['voucherId']?['product_name'] ?? '',
    );
  }

  static List<Winner> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((json) => Winner.fromJson(json)).toList();
  }
}
