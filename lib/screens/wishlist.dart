import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';
import '../services/wishlist.dart';
import 'cart_screen.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<WishlistItem> wishlistItems = [];
  List<Product> cartItems = [];
  Map<String, String> imageUrls = {};
  bool isLoading = true;
  String? token;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserAndFetchData();
  }

  Future<void> loadUserAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('authToken');
    userId = prefs.getString('userId');

    if (token != null && userId != null) {
      try {
        final fetchedWishlist = await WishlistService.fetchWishlist(token!);
        final fetchedCart = await WishlistService.fetchCart(userId!);
        setState(() {
          wishlistItems = fetchedWishlist;
          cartItems = fetchedCart;
        });
        // For each wishlist item, load its first image URL (if available)
        for (var item in fetchedWishlist) {
          if (item.product.imageIds.isNotEmpty) {
            String imageId = item.product.imageIds.first;
            String url = await WishlistService.fetchImageUrl(imageId);
            setState(() {
              imageUrls[imageId] = url;
            });
          }
        }
      } catch (e) {
        print("Error fetching data: $e");
      }
    } else {
      print("User not authenticated!");
    }
    setState(() {
      isLoading = false;
    });
  }

  // This method will add the product to the cart and then remove it from the wishlist.
  void handleAddToCartAndRemove(Product product) async {
    if (product.sizes != null && product.sizes!.isNotEmpty) {
      // Show popup for selecting size
      String? selectedSize = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String? tempSelectedSize = product.sizes!.first;
          return AlertDialog(
            title: Text("Select Size"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: product.sizes!.map((size) {
                return RadioListTile<String>(
                  title: Text(size),
                  value: size,
                  groupValue: tempSelectedSize,
                  onChanged: (String? value) {
                    tempSelectedSize = value;
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null), // Cancel
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(
                    context, tempSelectedSize), // Confirm selection
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      if (selectedSize == null) {
        return; // User canceled the selection
      }

      addToCartAndRemove(product, selectedSize);
    } else {
      // No size options, proceed with default
      addToCartAndRemove(product, "Default");
    }
  }

// Function to handle the cart addition and wishlist removal logic
  void addToCartAndRemove(Product product, String selectedSize) async {
    bool isInCart = cartItems.any((p) => p.id == product.id);

    if (!isInCart) {
      Map<String, dynamic> payload = {
        "userId": userId,
        "productId": product.id,
        "quantity": 1,
        "size": selectedSize,
        "price": product.salePrice,
        "walletDiscountApplied": false,
        "walletDiscountAmount": 0,
      };

      bool added = await WishlistService.addToCart(payload, token!);
      if (added) {
        setState(() {
          cartItems.add(product);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Could not add product to cart. Please try again.")),
        );
        return;
      }
    }

    // Remove from wishlist after adding to cart
    bool removed =
        await WishlistService.removeFromWishlist(userId!, product.id, token!);
    if (removed) {
      setState(() {
        wishlistItems.removeWhere((item) => item.product.id == product.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Product added to cart and removed from wishlist.")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove product from wishlist.")),
      );
    }
  }

  void handleRemoveFromWishlist(String productId) async {
    bool success =
        await WishlistService.removeFromWishlist(userId!, productId, token!);
    if (success) {
      setState(() {
        wishlistItems.removeWhere((item) => item.product.id == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product removed from wishlist successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Error removing product from wishlist. Please try again.")),
      );
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
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: const Text(
          'WishList',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: const Color.fromARGB(255, 195, 228, 239),
        child: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : wishlistItems.isEmpty
                  ? Center(
                      child: Text("No items in wishlist.",
                          style: TextStyle(fontSize: 18)),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: wishlistItems.map((item) {
                                bool isInCart = cartItems
                                    .any((p) => p.id == item.product.id);
                                String imageUrl = item
                                        .product.imageIds.isNotEmpty
                                    ? (imageUrls[item.product.imageIds.first] ??
                                        "https://via.placeholder.com/150")
                                    : "https://via.placeholder.com/150";
                                return Card(
                                  elevation: 4,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                item.product.description,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700]),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "₹${formatCurrency(item.product.salePrice)}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        handleAddToCartAndRemove(
                                                            item.product),
                                                    icon: Icon(isInCart
                                                        ? Icons.shopping_cart
                                                        : Icons
                                                            .add_shopping_cart),
                                                    label: Text(isInCart
                                                        ? "Go to Cart"
                                                        : "Add to Cart"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: isInCart
                                                          ? Colors.green
                                                          : Colors.amber,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  IconButton(
                                                    onPressed: () =>
                                                        handleRemoveFromWishlist(
                                                            item.product.id),
                                                    icon: Icon(Icons.delete,
                                                        color:
                                                            Colors.redAccent),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
