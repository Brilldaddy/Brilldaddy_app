import 'package:flutter/material.dart';
import '../../widgets/product_card.dart';
import '/services/api_service.dart';
import '/models/product.dart';


class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  Map<String, bool> wishlist = {};
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      List<Product> loadedProducts = await _apiService.fetchProducts();

      // Fetch image URLs for each product
      for (var product in loadedProducts) {
        List<String> imageUrls = await _apiService.fetchImageUrls(product.imageIds);
        product.imageUrls = imageUrls;
      }

      setState(() {
        products = loadedProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void toggleFavorite(String productId) {
    setState(() {
      wishlist[productId] = !(wishlist[productId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductGrid(
              products: products,
              visibleCount: 10,
              toggleFavorite: toggleFavorite,
              wishlist: wishlist,
            ),
    );
  }
}
