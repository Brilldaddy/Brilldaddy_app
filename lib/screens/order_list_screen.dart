import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'auth.dart';
import 'order_detail_screen.dart'; // Create this screen for order details

const String SERVER_URL = "https://api.brilldaddy.com/api";

class OrdersList extends StatefulWidget {
  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  List orders = [];
  bool isLoading = true;
  Map<String, String> imageUrls = {};
  int? selectedRating;
  String userId = '';
  String token = '';
  String? selectedProduct;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

     @override
void dispose() {
  super.dispose();
}

  Future<void> fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    token = prefs.getString('authToken') ?? '';

    try {
      final response =
          await http.get(Uri.parse('$SERVER_URL/user/orders/$userId'));
      final data = jsonDecode(response.body);

      List fetchedOrders = [];

      if (data is List) {
        fetchedOrders = data;
      } else if (data is Map && data.containsKey('orders')) {
        fetchedOrders = data['orders'];
      } else {
        throw Exception("Unexpected response format");
      }

      // Sort orders by `createdAt` in descending order (latest first)
      fetchedOrders.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(0);
        DateTime dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(0);
        return dateB.compareTo(dateA); // Latest order first
      });

      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });

      fetchImages(fetchedOrders);
    } catch (error) {
      print("Error fetching orders: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchImages(List orders) async {
    Map<String, String> imageUrlsMap = {};
    for (var order in orders) {
      for (var item in order['cartItems']) {
        String imageId = item['productId']['images'][0] is int
            ? item['productId']['images'][0].toString()
            : item['productId']['images'][0];

        print("Image ID: $imageId");
        final imageResponse =
            await http.get(Uri.parse('$SERVER_URL/user/images/$imageId'));
        imageUrlsMap[imageId] = jsonDecode(imageResponse.body)['imageUrl'];
      }
    }
    if (!mounted) return;
    setState(() => imageUrls = imageUrlsMap);
  }

  void openRatingModal(String productId) {
    setState(() {
      selectedProduct = productId;
      selectedRating = 0;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate this product"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                Icons.star,
                color:
                    index < (selectedRating ?? 0) ? Colors.yellow : Colors.grey,
              ),
              onPressed: () => setState(() => selectedRating = index + 1),
            );
          }),
        ),
        actions: [
          TextButton(
            child: Text("Submit"),
            onPressed: submitRating,
          )
        ],
      ),
    );
  }

  Future<void> submitRating() async {
    if (selectedProduct == null || selectedRating == 0) return;
    try {
      await http.post(
        Uri.parse('$SERVER_URL/user/rate-product'),
        body: jsonEncode({
          'productId': selectedProduct,
          'userId': 'USER_ID',
          'rating': selectedRating,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rating submitted successfully!")),
      );
      Navigator.pop(context);
    } catch (error) {
      print("Error submitting rating: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 195, 228, 239),
        appBar: AppBar(
          title: Text("Order History", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? Center(child: Text("No Orders Found"))
                : ListView.builder(
                    reverse: true,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order =
                          orders[index]; // Orders already sorted, latest first
                      return Column(
                        children: order['cartItems'].map<Widget>((item) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(
                                  productId:
                                      item['productId']['_id'].toString(),
                                  id: order['_id'].toString(),
                                  orderStatus: item['status'], // Add this line
                                ),
                              ),
                            ),
                            child: Card(
                              margin: EdgeInsets.all(8),
                              child: ListTile(
                                leading: Image.network(
                                    imageUrls[item['productId']['images'][0]] ??
                                        '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover),
                                title: Text(item['productId']['name']),
                                subtitle: Text(
                                    "₹${item['price']} - Qty: ${item['quantity']}"),
                                trailing: item['status'] == "Delivered"
                                    ? TextButton(
                                        onPressed: () => openRatingModal(
                                            item['productId']['_id']),
                                        child: Text("Rate",
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      )
                                    : Text(item['status']),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ));
  }




}
