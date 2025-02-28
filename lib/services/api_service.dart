import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/voucher.dart';

class ApiService {
  final String _baseUrl = 'https://api.brilldaddy.com/api';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/user/products'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData is List) {
        return decodedData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to load products');
    }
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

  /// Fetch advertisements for the carousel
  Future<List<String>> fetchAdvertisements() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/user/carousel'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item['imageUrl'].toString()).toList();
      } else {
        throw Exception('Failed to load carousel images');
      }
    } catch (e) {
      throw Exception('Error fetching carousel images: $e');
    }
  }

  Future<List<Voucher>> fetchVouchers() async {
    final response = await http.get(Uri.parse('$_baseUrl/voucher/getVouchers'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Voucher.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch vouchers");
    }
  }

  Future<List<dynamic>> getWinners() async {
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/voucher/getWinners"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load winners');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/user/category'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (error) {
      throw Exception("Error fetching categories: $error");
    }
  }
}
