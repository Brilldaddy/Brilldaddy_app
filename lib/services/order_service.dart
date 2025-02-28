// order_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order.dart';

class OrderService {
  final String baseUrl = 'https://api.brilldaddy.com/api';

  Future<List<Order>> fetchOrders(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/orders/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print("Response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          // If the response data contains a list of orders
          return (responseData['data'] as List)
              .map((json) => Order.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (responseData['data'] is Map<String, dynamic>) {
          // If the response contains a single order object, wrap it in a list
          return [Order.fromJson(responseData['data'])];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order> fetchOrderDetails(String orderId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/order/$orderId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final orderData = responseData['data'] ?? responseData;
        return Order.fromJson(orderData);
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  Future<void> cancelOrder(
      String orderId, String token, Map<String, dynamic> cancelDetails) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/cancel-order/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(cancelDetails),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel order: ${response.statusCode}');
    }
  }

  Future<void> returnOrder(
      String orderId, String token, Map<String, dynamic> returnDetails) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/return-order/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(returnDetails),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to return order: ${response.statusCode}');
    }
  }
}
