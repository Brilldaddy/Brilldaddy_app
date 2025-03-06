import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';

class CartService {
  static const String _baseUrl = "https://api.brilldaddy.com/api/user";

  /// **Fetch Cart Items**
 static Future<Cart?> getCart(String userId, String authToken) async {
  if (userId.isEmpty || authToken.isEmpty) {
    print("User ID or Auth Token is missing.");
    return null;
  }

  final response = await http.get(
    Uri.parse("$_baseUrl/cart/$userId"),
    headers: {
      "Authorization": "Bearer $authToken",
      "Content-Type": "application/json",
    },
  );


  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);


    if (responseData is List) {
      // ✅ Convert list of JSON objects into List<CartItem>
      List<CartItem> items =
          responseData.map((item) => CartItem.fromJson(item)).toList();
      
      // ✅ Construct a Cart object manually (since API does not return userId)
      return Cart(userId: userId, items: items);
    } else {
      print("Error: Expected List but got something else.");
    }
  } else {
    print("Failed to fetch cart. Status Code: ${response.statusCode}");
  }

  return null;
}


Future<List<String>> fetchImageUrls(List<String> imageIds) async {
    List<String> imageUrls = [];

    for (String id in imageIds) {
      final response = await http.get(Uri.parse('$_baseUrl/user/images/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Add primary image URL
        if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty) {
          imageUrls.add(data['imageUrl']);
        }

        // Add sub-image URLs
        if (data['subImageUrl'] != null && data['subImageUrl'] is List) {
          imageUrls.addAll(List<String>.from(data['subImageUrl']));
        }
      } else {
        print('Failed to load image for $id. Response: ${response.body}');
      }
    }
    return imageUrls;
  }


  /// **Add Item to Cart**
 static Future<bool> addToCart(Map<String, dynamic> cartData) async {
  try {
    final url = Uri.parse('$_baseUrl/cart/add');
    print("Sending payload: ${jsonEncode(cartData)}");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${cartData['authToken']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(cartData),
    );
    print("Add to cart response: ${response.statusCode} ${response.body}");
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 &&
        responseData.containsKey('message') &&
        responseData['message'] == "Product added to cart successfully") {
      return true;
    } else {
      print('Cart API Error: $responseData');
      return false;
    }
  } catch (e) {
    print('Error in addToCart API: $e');
    return false;
  }
}


  /// **Remove Item from Cart**
  static Future<bool> removeFromCart(String productId, String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final authToken = prefs.getString('authToken');

    if (userId == null || authToken == null) return false;

    final response = await http.delete(
      Uri.parse("$_baseUrl/cart/$userId/$productId"),
      headers: {
        "Authorization": "Bearer $authToken",
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200;
  }

  /// **Clear Entire Cart**
  static Future<bool> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final authToken = prefs.getString('authToken');

    if (userId == null || authToken == null) return false;

    final response = await http.delete(
      Uri.parse("$_baseUrl/clearCart/$userId"),
      headers: {
        "Authorization": "Bearer $authToken",
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200;
  }

  /// **Update Quantity**
 static Future<bool> updateQuantity(String productId, int quantity) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final authToken = prefs.getString('authToken');

  if (userId == null || authToken == null) return false;

  final response = await http.put(
    Uri.parse("$_baseUrl/cart/$userId/$productId"),
    headers: {
      "Authorization": "Bearer $authToken",
      "Content-Type": "application/json",
    },
    body: jsonEncode({"quantity": quantity}),
  );

  return response.statusCode == 200;
}

}
