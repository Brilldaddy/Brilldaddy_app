import 'package:brilldaddy/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_services.dart';
import 'cart_screen.dart';
import '../services/wishlist.dart';
import 'checkout.dart'; // Ensure you have methods to add/remove wishlist

class ProductDetailPage extends StatefulWidget {
  final Product product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isWishlisted = false;
  bool isAddedToCart = false;
  bool isInCart = false;
  bool isLoading = false;
  String errorMessage = '';
  late Future<List<String>> _imageUrls;

  // For size selection (if applicable)
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    checkCartStatus();
    checkWishlistStatus();
    // If product has sizes, initialize selectedSize with the first available size.
    if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) {
      selectedSize = widget.product.sizes!.first;
    }
    _imageUrls = ApiService().fetchImageUrls(widget.product.imageIds)
      ..then((urls) {
        print("Fetched Image URLs: $urls"); // Debugging
      });
  }

  Future<void> checkCartStatus() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId')?.trim();
      final authToken = prefs.getString('authToken')?.trim();

      if (userId != null && authToken != null) {
        final cart = await CartService.getCart(userId, authToken);
        if (cart != null) {
          final isProductInCart =
              cart.items.any((item) => item.product.id == widget.product.id);

          if (mounted) {
            setState(() {
              isInCart = isProductInCart;
            });
          }
        }
      }
    } catch (e) {
      print('Error checking cart status: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> checkWishlistStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken')?.trim();
    if (token == null) return;
    try {
      final wishlist = await WishlistService.fetchWishlist(token);
      bool exists =
          wishlist.any((item) => item.product.id == widget.product.id);
      setState(() {
        isWishlisted = exists;
      });
    } catch (e) {
      print("Error checking wishlist status: $e");
    }
  }

  void toggleWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken')?.trim();
    final userId = prefs.getString('userId')?.trim();

    if (token == null || userId == null) {
      showSnackBar('Please login to continue');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    if (isWishlisted) {
      bool success = await WishlistService.removeFromWishlist(
          userId, widget.product.id, token);
      if (success) {
        setState(() {
          isWishlisted = false;
        });
        showSnackBar('Removed from Wishlist');
      }
    } else {
      bool success =
          await WishlistService.addToWishlist(userId, widget.product.id, token);
      if (success) {
        setState(() {
          isWishlisted = true;
        });
        showSnackBar('Added to Wishlist');
      } else {
        showSnackBar('Failed to add to Wishlist');
      }
    }
  }

  Future<void> handleAddToCartAndRemove() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId')?.trim();
    final authToken = prefs.getString('authToken')?.trim();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn ||
        userId == null ||
        userId.isEmpty ||
        authToken == null ||
        authToken.isEmpty) {
      showSnackBar('Please login to continue');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    // If product has sizes and no size is selected, show error.
    if (widget.product.sizes != null &&
        widget.product.sizes!.isNotEmpty &&
        selectedSize == null) {
      showSnackBar('Please select a size');
      return;
    }

    final cartData = {
      'userId': userId,
      'productId': widget.product.id,
      'quantity': 1,
      'price': widget.product.salePrice,
      'selectedSize': selectedSize ?? "N/A",
      'authToken': authToken,
    };

    setState(() {
      isLoading = true;
    });

    final success = await CartService.addToCart(cartData);
    if (success) {
      showSnackBar('Product added to cart successfully!');
      setState(() {
        isInCart = true;
      });
      bool removed = await WishlistService.removeFromWishlist(
          userId, widget.product.id, authToken);
      if (removed) {
        setState(() {
          isWishlisted = false;
        });
      }
    } else {
      showSnackBar('Failed to add to cart. Please try again.');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Widget buildImageCarousel(List<String> imageUrls) {
    List<String> uniqueImageUrls =
        imageUrls.toSet().toList(); // Remove duplicates

    return Hero(
      tag: widget.product.name,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 250,
          enableInfiniteScroll: true,
          enlargeCenterPage: true,
        ),
        items: uniqueImageUrls.map((url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade300,
                child: Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildProductTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.product.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.red : Colors.grey,
          ),
          onPressed: toggleWishlist,
        ),
      ],
    );
  }

  Widget buildRating() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.orange, size: 20),
        Icon(Icons.star, color: Colors.orange, size: 20),
        Icon(Icons.star, color: Colors.orange, size: 20),
        Icon(Icons.star_half, color: Colors.orange, size: 20),
        Icon(Icons.star_border, color: Colors.orange, size: 20),
        SizedBox(width: 8),
        Text('4.5 (120 reviews)',
            style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget buildPriceInfo() {
    return Row(
      children: [
        Text(
          '₹${widget.product.salePrice}',
          style: TextStyle(
              fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        if (widget.product.productPrice > widget.product.salePrice)
          Text(
            '₹${widget.product.productPrice}',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough),
          ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.product.discount}% off',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(widget.product.description,
            style: TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  /// Build size selector if the product has sizes.
  Widget buildSizeSelector() {
    if (widget.product.sizes == null || widget.product.sizes!.isEmpty)
      return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Size",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.product.sizes!.map((size) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(size),
                  selected: selectedSize == size,
                  onSelected: (selected) {
                    setState(() {
                      selectedSize = selected ? size : null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildBottomBar() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : (isInCart
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartScreen()),
                          );
                        }
                      : handleAddToCartAndRemove),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: isInCart ? Colors.green : Colors.blue,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isInCart ? 'Go to Cart' : 'Add to Cart',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckoutScreen(product: widget.product),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.orange,
              ),
              child: Text('Buy Now',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.white,
            ),
            onPressed: toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
              future: _imageUrls,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading images"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No images available"));
                } else {
                  return buildImageCarousel(snapshot.data!);
                }
              },
            ),
            SizedBox(height: 16),
            buildProductTitle(),
            SizedBox(height: 8),
            buildRating(),
            SizedBox(height: 16),
            buildPriceInfo(),
            SizedBox(height: 16),
            buildDescription(),
            SizedBox(height: 16),
            // Only show size selector if product has sizes
            buildSizeSelector(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }
}
