import 'dart:convert';

class Winner {
  final String id;
  final String prize;
  final String bidId;
  final String username;
  final String state;

  Winner({
    required this.id,
    required this.prize,
    required this.bidId,
    required this.username,
    required this.state,
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      id: json['id'] ?? '',
      prize: json['prize'] ?? '',
      bidId: json['winningBidId']?['bidId'] ?? '',
      username: json['userId']?['username'] ?? '',
      state: json['userId']?['currentAddress']?['state'] ?? '',
    );
  }

   static List<Winner> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((json) => Winner.fromJson(json)).toList();
  }
}
