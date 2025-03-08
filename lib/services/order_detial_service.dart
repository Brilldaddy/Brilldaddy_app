import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderDetailService {
  static const String SERVER_URL = "https://api.brilldaddy.com/api";

  static Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    final response =
        await http.get(Uri.parse('$SERVER_URL/user/order/$orderId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch order details: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchAddress(String addressId) async {
    final response =
        await http.get(Uri.parse('$SERVER_URL/user/address/$addressId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch address: ${response.body}');
    }
  }

  static Future<String> fetchImageUrl(String imageId) async {
    final response =
        await http.get(Uri.parse('$SERVER_URL/user/images/$imageId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['imageUrl'];
    } else {
      throw Exception('Failed to fetch image URL: ${response.body}');
    }
  }

  static Future<bool> cancelOrder(
    String orderId,
    String userId,
    String productId,
    String reason,
    Map<String, String> bankDetails,
    Map<String, dynamic> orderDetails,
  ) async {
    final url = Uri.parse('$SERVER_URL/admin/cancel-order/$orderId');

    final Map<String, dynamic> requestBody = {
      "userId": userId,
      "orderId": orderId,
      "productId": productId,
      "cancelReason": reason,
      "bankDetails": {
        "accountNumber": bankDetails["accountNumber"] ?? "",
        "ifscCode": bankDetails["ifscCode"] ?? "",
        "branch": bankDetails["branch"] ?? "",
        "accountHolderName": bankDetails["accountHolderName"] ?? ""
      },
      "orderDetails": {
        "orderId": orderDetails["orderId"] ?? "",
        "orderDate": orderDetails["orderDate"] ?? "",
        "totalAmount": orderDetails["totalAmount"] ?? 0.0
      }
    };

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> fetchOrderDetailsForInvoice(
      String orderId) async {
    final response =
        await http.get(Uri.parse('$SERVER_URL/admin/order/$orderId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to fetch order details for invoice: ${response.body}');
    }
  }
}
