import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/product.dart';
import '../../screens/Single_Product.dart';
import '../../services/api_service.dart';
import '../../services/wishlist.dart';

class CategoryProductList extends StatefulWidget {
  const CategoryProductList({Key? key}) : super(key: key);

  @override
  _CategoryProductListState createState() => _CategoryProductListState();
}

class _CategoryProductListState extends State<CategoryProductList> {
  bool isLoading = true;
  Map<String, List<Product>> categorizedProducts = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse("$SERVER_URL/user/products");
    print("Fetching products from: $url");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Product> allProducts = data.map((json) => Product.fromJson(json)).toList();

        // Fetch image URLs separately
        for (var product in allProducts) {
          if (product.imageIds.isNotEmpty) {
            product.imageUrls = await ApiService().fetchImageUrls(product.imageIds);
          }
        }

        // Group products by category
        Map<String, List<Product>> groupedProducts = {};
        for (var product in allProducts) {
          String category = product.category.trim().toLowerCase();
          if (!groupedProducts.containsKey(category)) {
            groupedProducts[category] = [];
          }
          groupedProducts[category]!.add(product);
        }

        setState(() {
          categorizedProducts = groupedProducts;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching products: $e";
        isLoading = false;
      });
    }
  }

  String formatCurrency(num value) {
    return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+\.)'),
          (match) => '${match[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : categorizedProducts.isEmpty
                ? Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categorizedProducts.keys.map((category) {
                      List<Product> products = categorizedProducts[category]!;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 250, // Adjust height for horizontal scrolling
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final String imageUrl = (product.imageUrls != null &&
                                          product.imageUrls is List &&
                                          product.imageUrls!.isNotEmpty)
                                      ? (product.imageUrls!.first
                                              .toString()
                                              .startsWith("http")
                                          ? product.imageUrls!.first.toString()
                                          : "$SERVER_URL/uploads/${product.imageUrls!.first.toString()}")
                                      : "https://dummyimage.com/150x150/cccccc/000000&text=No+Image";

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailPage(product: product),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150, // Adjust width for each product card
                                      margin: const EdgeInsets.only(right: 16),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                              child: Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                height: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.network(
                                                      "https://dummyimage.com/150x150/cccccc/000000&text=No+Image",
                                                      height: 150);
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Text(
                                                "₹${formatCurrency(product.salePrice)}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            if (product.productPrice > product.salePrice)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                                child: Text(
                                                  "₹${formatCurrency(product.productPrice)}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                      decoration:
                                                          TextDecoration.lineThrough),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
  }
}