import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../component/account/AddressFormPage.dart';
import '../models/product.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'payment_success.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;

  CheckoutScreen({required this.product});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedAddressId;
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;
  String errorMessage = '';
  int quantity = 1;
  late Razorpay _razorpay;
  final TextEditingController _contactController = TextEditingController();
  String? razorpayOrderId; // Stores the created Razorpay order ID

  @override
  void initState() {
    super.initState();
    fetchUserAddresses();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> createRazorpayOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken')?.trim();
      final userId = prefs.getString('userId')?.trim();

      if (authToken == null || userId == null) {
        Fluttertoast.showToast(msg: "User not authenticated.");
        return;
      }

      double totalAmount = widget.product.salePrice * quantity;

      final response = await http.post(
        Uri.parse("https://api.brilldaddy.com/api/user/checkout/createOrder"),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "amount": totalAmount,
          "receipt": "order_${DateTime.now().millisecondsSinceEpoch}"
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        setState(() {
          razorpayOrderId = responseData['order']['id']; // Store order ID
        });
        startPayment();
      } else {
        Fluttertoast.showToast(msg: "Failed to create order.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> startPayment() async {
    if (_contactController.text.isEmpty || _contactController.text.length != 10) {
      Fluttertoast.showToast(msg: "Please enter a valid 10-digit contact number.");
      return;
    }

    if (razorpayOrderId == null) {
      Fluttertoast.showToast(msg: "Order ID is missing.");
      return;
    }

    double totalAmount = widget.product.salePrice * quantity * 100;

    var options = {
      'key': 'rzp_test_yjMX4hSQ75uCRn',
      'amount': totalAmount.toInt(),
      'currency': 'INR',
      'name': 'BRILLDADDY ECOMMERCE PVT LTD.',
      'description': 'Payment for ${widget.product.name}',
      'order_id': razorpayOrderId, // Attach Razorpay order ID
      'prefill': {'contact': _contactController.text, 'email': 'user@example.com'},
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  if (response.paymentId != null) {
    Fluttertoast.showToast(msg: "Payment Successful: ${response.paymentId}");
    await placeOrder(response.paymentId!); 

  } else {
    Fluttertoast.showToast(msg: "Payment ID is missing.");
  }
}


  Future<void> placeOrder(String paymentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId')?.trim();
      final authToken = prefs.getString('authToken')?.trim();

      if (userId == null || authToken == null) {
        Fluttertoast.showToast(msg: "User authentication failed.");
        return;
      }

      final url = Uri.parse("https://api.brilldaddy.com/api/user/checkout/placeorder");

      final orderData = {
        "userId": userId,
        "cartItems": [
          {
            "productId": widget.product.id,
            "quantity": quantity,
            "price": widget.product.salePrice,
            "size": widget.product.sizes?.isNotEmpty == true ? widget.product.sizes![0] : ""
          }
        ],
        "selectedAddressId": selectedAddressId,
        "paymentMethod": "Razorpay",
        "paid": true
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Order placed successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentSuccessPage(cartItems: [], userId: userId)),
        );
      } else {
        Fluttertoast.showToast(msg: "Failed to place order.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error placing order: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet Used: ${response.walletName}");
  }

  Future<void> fetchUserAddresses() async {
    setState(() { isLoading = true; errorMessage = ''; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId')?.trim();
      final authToken = prefs.getString('authToken')?.trim();

      if (userId == null || authToken == null) {
        setState(() { errorMessage = "Please log in to proceed."; isLoading = false; });
        return;
      }

      final response = await http.get(
        Uri.parse("https://api.brilldaddy.com/api/user/addresses/$userId"),
        headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          addresses = List<Map<String, dynamic>>.from(data);
          if (addresses.isNotEmpty) {
            selectedAddressId = addresses[0]['_id'];
          }
        });
      } else {
        setState(() { errorMessage = "Failed to load addresses."; });
      }
    } catch (e) {
      setState(() { errorMessage = "An error occurred: $e"; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  void _showContactInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Contact Number"),
          content: TextField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: "Enter your 10-digit phone number"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(onPressed: () { Navigator.pop(context); createRazorpayOrder(); }, child: Text("Proceed")),
          ],
        );
      },
    );
  }
  
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "Add Address",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddressFormPage(onRefresh: fetchUserAddresses)),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Details Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Product Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      (widget.product.imageUrls
                                                  is List<String> &&
                                              widget.product.imageUrls!
                                                  .isNotEmpty)
                                          ? widget.product.imageUrls![
                                              0] // Take the first image if it's a list
                                          : (widget.product.imageUrls is String
                                              ? widget.product.imageUrls
                                                  as String
                                              : 'https://via.placeholder.com/80'),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),

                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),

                                    // Selected Size (if available)
                                    if (widget.product.sizes != null &&
                                        widget.product.sizes!.isNotEmpty)
                                      Text(
                                        "Size: ${widget.product.sizes!.join(', ')}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blueAccent,
                                        ),
                                      ),

                                    SizedBox(height: 8),

                                    Text(
                                      "Price: ₹${widget.product.salePrice}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Select Address Section
                      Text("Select Address:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final address = addresses[index];
                            return Card(
                              child: ListTile(
                                leading: Radio<String>(
                                  value: address['_id'],
                                  groupValue: selectedAddressId,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAddressId = value;
                                    });
                                  },
                                ),
                                title: Text(address['userName'] ?? 'Name'),
                                subtitle: Text(
                                    "${address['flatNumber']}, ${address['street']}, ${address['state']}, ${address['pincode']}"),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      // Proceed to Payment Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedAddressId == null
                              ? null
                              : _showContactInputDialog,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          child: Text(
                            "Proceed to Payment",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
