import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/wishlist_item.dart';

const String SERVER_URL = "https://api.brilldaddy.com/api";

class WishlistService {
  static Future<List<WishlistItem>> fetchWishlist(String token) async {
    final response = await http.get(
      Uri.parse("$SERVER_URL/user/wishlist"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => WishlistItem.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch wishlist");
    }
  }

  // Add product to wishlist.
  static Future<bool> addToWishlist(String userId, String productId, String token) async {
    final url = Uri.parse("$SERVER_URL/user/wishlist");
    final payload = {
      "userId": userId,
      "productId": productId,
    };
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    print("Add to wishlist response: ${response.statusCode} ${response.body}");
    return response.statusCode == 200;
  }

  static Future<List<Product>> fetchCart(String userId) async {
    final response = await http.get(Uri.parse("$SERVER_URL/user/cart/$userId"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // Assuming each cart item contains a nested product object under "productId"
      return data.map((item) => Product.fromJson(item['productId'])).toList();
    } else {
      throw Exception("Failed to fetch cart");
    }
  }

Future<Map<String, dynamic>> addToWishlistcart(String userId, String productId, String authToken) async {
  final response = await http.post(
    Uri.parse('$SERVER_URL/user/wishlist'),
    headers: {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'userId': userId, 'productId': productId}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body); // Return the JSON response
  } else {
    return {'wishlistStatus': 'failed'}; // Ensure it always returns a Map
  }
}


  static Future<String> fetchImageUrl(String imageId) async {
    final response = await http.get(Uri.parse("$SERVER_URL/user/images/$imageId"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'] ?? "";
    } else {
      return "";
    }
  }

  static Future<bool> addToCart(Map<String, dynamic> payload, String token) async {
    final response = await http.post(
      Uri.parse("$SERVER_URL/user/cart/add"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    // Optionally, print response for debugging:
    print("Add to cart response: ${response.statusCode} ${response.body}");
    return response.statusCode == 200;
  }

  static Future<bool> removeFromWishlist(String userId, String productId, String token) async {
    final response = await http.delete(
      Uri.parse("$SERVER_URL/user/wishlist/remove"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "productId": productId}),
    );
    return response.statusCode == 200;
  }
}
