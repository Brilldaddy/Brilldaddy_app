import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_models.dart';
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
}
