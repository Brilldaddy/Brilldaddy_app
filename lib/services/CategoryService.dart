import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_models.dart';
import '../models/product.dart';
import 'wishlist.dart';

class CategoryService {
  static Future<List<Category>> fetchCategories(String token) async {
    final response = await http.get(
      Uri.parse("$SERVER_URL/user/category"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch categories");
    }
  }

  static Future<Map<String, List<Product>>> fetchCategoriesAndProducts(
      String token) async {
    final response = await http.get(
      Uri.parse("$SERVER_URL/user/categoriesAndProducts"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, List<Product>> result = {};

      data.forEach((key, value) {
        if (value is List) {
          result[key] = value.map((item) => Product.fromJson(item)).toList();
        } else {
          // Log or skip invalid category data
          print("Invalid data format for category: $key");
        }
      });

      return result;
    } else {
      throw Exception("Failed to fetch categories and products");
    }
  }
}
