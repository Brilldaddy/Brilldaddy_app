import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../services/cart_services.dart';
import '../services/wishlist.dart';
import 'AddressSelectionScreen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Cart? cart;
  bool isLoading = true;
  String? authToken;
  Map<String, String> imageUrls = {};

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final tokenFromPrefs = prefs.getString('authToken');

    if (userId == null || tokenFromPrefs == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => authToken = tokenFromPrefs);

    try {
      Cart? fetchedCart = await CartService.getCart(userId, tokenFromPrefs);
      if (!mounted) return;

      if (fetchedCart != null && fetchedCart.items.isNotEmpty) {
        Map<String, String> imageMap = {};
        for (var item in fetchedCart.items) {
          print("Product ID: ${item.product.id}, Image URLs: ${item.product.imageUrls}");
          print("Product ID: ${item.product.id}, Image URLs: ${item.product.imageIds}");

          if (item.product.imageIds != null && item.product.imageIds.isNotEmpty) {
            final imageUrl = await CartService.fetchImageUrl(item.product.imageIds[0]);
            imageMap[item.product.id] = imageUrl;
          } else {
            imageMap[item.product.id] =
                "https://dummyimage.com/150x150/cccccc/000000&text=No+Image";
          }
        }

        setState(() {
          cart = fetchedCart;
          imageUrls = imageMap;
          isLoading = false;
        });
      } else {
        setState(() {
          cart = fetchedCart;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching cart: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> removeItem(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final authToken = prefs.getString('authToken');

    if (userId != null && authToken != null) {
      final success = await CartService.removeFromCart(productId, authToken);
      if (success) {
        fetchCart();
      }
    }
  }

  void updateItemQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) return; // Prevent negative or zero quantity

    bool success = await CartService.updateQuantity(productId, newQuantity);
    if (success) {
      fetchCart(); // Refresh the cart data on success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update quantity")),
      );
    }
  }

  // When the user clicks "Add to Wishlist", add the product to the wishlist
  // and then remove it from the cart.
  Future<void> addToWishlistAndRemoveFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final authToken = prefs.getString('authToken');

    if (userId == null || authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    try {
      final wishlistService = WishlistService();
      final response =
          await wishlistService.addToWishlistcart(userId, productId, authToken);

      print("Wishlist API response: $response");

      if (response != null && response.containsKey('_id')) {
        print("Product successfully added to wishlist");
        bool removeSuccess =
            await CartService.removeFromCart(productId, authToken);
        if (removeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product moved to wishlist")),
          );
          fetchCart();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to remove item from cart")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add to wishlist")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
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
    double totalPrice = cart?.items
            .fold(0, (sum, item) => sum! + (item.price * item.quantity)) ??
        0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cart == null || cart!.items.isEmpty
              ? Center(
                  child: Text(
                    '🛒 Your cart is empty!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: cart!.items.length,
                        itemBuilder: (context, index) {
                          final item = cart!.items[index];
                          String imageUrl = imageUrls[item.product.id] ??
                              "https://dummyimage.com/150x150/cccccc/000000&text=No+Image";

                          print(
                              "Final Image URL for ${item.product.name}: $imageUrl");

                          return Dismissible(
                            key: Key(item.product.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) =>
                                removeItem(item.product.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.redAccent,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                            "https://dummyimage.com/150x150/cccccc/000000&text=No+Image",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),

                                          // Only display the size if the product has a selected size
                                          // ignore: unrelated_type_equality_checks
                                          if (item.size != null &&
                                              item.size!.isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: Text(
                                                "Size: ${item.size}",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                            ),

                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                "₹${item.price.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green),
                                              ),
                                              const SizedBox(width: 10),
                                              const Text(
                                                "x",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(width: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.remove,
                                                          size: 18),
                                                      onPressed: () =>
                                                          updateItemQuantity(
                                                              item.product.id,
                                                              item.quantity -
                                                                  1),
                                                    ),
                                                    Text(
                                                      item.quantity < 1
                                                          ? '1'
                                                          : item.quantity
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.add,
                                                          size: 18),
                                                      onPressed: () =>
                                                          updateItemQuantity(
                                                              item.product.id,
                                                              item.quantity +
                                                                  1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              TextButton.icon(
                                                onPressed: () =>
                                                    addToWishlistAndRemoveFromCart(
                                                        item.product.id),
                                                icon: const Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.pink,
                                                    size: 18),
                                                label: const Text(
                                                    "Add to Wishlist",
                                                    style: TextStyle(
                                                        color: Colors.pink)),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.redAccent),
                                                onPressed: () =>
                                                    removeItem(item.product.id),
                                              ),
                                            ],
                                          ),
                                        ],
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
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10)
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "₹${totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddressSelectionScreen(
                                              totalAmount: totalPrice,
                                              cartItems: cart?.items ?? [])),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Proceed to Checkout",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
