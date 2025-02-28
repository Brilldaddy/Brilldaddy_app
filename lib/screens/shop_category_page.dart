import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/wishlist.dart';
import 'Single_Product.dart'; // If needed for wishlist functions for $SERVER_URL

class ShopCategoryPage extends StatefulWidget {
  final String category;
  const ShopCategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  _ShopCategoryPageState createState() => _ShopCategoryPageState();
}

class _ShopCategoryPageState extends State<ShopCategoryPage> {
  bool isLoading = true;
  List<Product> products = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
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

      setState(() {
        products = allProducts.where((product) {
          return product.category.trim().toLowerCase() ==
              widget.category.trim().toLowerCase();
        }).toList();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : products.isEmpty
                  ? Center(
                      child: Text(
                        "No products found for '${widget.category}'.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
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

                          // print(
                          //     "Image URL for product ${product.name}: $imageUrl");
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(product: product),
                                ),
                              );
                              // Navigate to product detail page if needed
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print(
                                              "Error loading image for ${product.name}: $error");
                                          return Image.network(
                                              "https://dummyimage.com/150x150/cccccc/000000&text=No+Image",
                                              height: 150);
                                        },
                                      ),
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
                          );
                        },
                      ),
                    ),
    );
  }
}
