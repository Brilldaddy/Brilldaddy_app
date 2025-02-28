// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/winner.dart';

const String SERVER_URL = "https://api.brilldaddy.com/api";

class VoucherApiService {
  Future<List<Winner>> fetchWinners(String voucherId) async {
    final url =
        Uri.parse('$SERVER_URL/voucher/getWinners?voucherId=$voucherId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentTime = DateTime.now();

        return data
            .where((winnerJson) {
              final endTime = DateTime.tryParse(winnerJson['endTime'] ?? '');
              return endTime != null && endTime.isAfter(currentTime);
            })
            .map((winnerJson) => Winner.fromJson(winnerJson))
            .toList();
      } else {
        throw Exception("Failed to fetch winners");
      }
    } catch (e) {
      throw Exception("Error fetching winners: $e");
    }
  }

  Future<bool> confirmBid(
      String userId, String voucherId, double bidAmount, String bidId) async {
    final url = Uri.parse('$SERVER_URL/bid/confirmBid');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "voucherId": voucherId,
          "bidAmount": bidAmount,
          "bidId": bidId,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Failed to place bid.');
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
