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

  @override
  void initState() {
    super.initState();
    fetchUserAddresses();
    quantity = 1;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchUserAddresses() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId')?.trim();
      final authToken = prefs.getString('authToken')?.trim();

      if (userId == null || authToken == null) {
        setState(() {
          errorMessage = "Please log in to proceed.";
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse("https://api.brilldaddy.com/api/user/addresses/$userId");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          addresses = List<Map<String, dynamic>>.from(data);
          if (addresses.isNotEmpty) {
            selectedAddressId = addresses[0]['_id'];
          }
        });
      } else {
        setState(() {
          errorMessage = "Failed to load addresses.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Payment Successful: ${response.paymentId}");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(cartItems: [], userId: ''),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet Used: ${response.walletName}");
  }

  void startPayment() {
      double totalAmount = widget.product.salePrice * quantity * 100;

    var options = {
      'key': 'rzp_test_yjMX4hSQ75uCRn',
      'amount': totalAmount.toInt(),
      'currency': 'INR',
      'name': 'BRILLDADDY ECOMMERCE PVT LTD.',
      'description': 'Payment for ${widget.product.name}',
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com',
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
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
                    builder: (context) => AddressFormPage(onRefresh: fetchUserAddresses)),
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
                                    SizedBox(height: 10),

                                    // Quantity Selector
                                    Row(
                                      children: [
                                        Text(
                                          "Quantity:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: decreaseQuantity,
                                              ),
                                              Text(
                                                quantity.toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: increaseQuantity,
                                              ),
                                            ],
                                          ),
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

                      SizedBox(height: 20),
                      Text("Select Address:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                subtitle: Text("${address['flatNumber']}, ${address['street']}, ${address['state']}, ${address['pincode']}"),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: selectedAddressId == null ? null : startPayment,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                          child: Text("Proceed to Payment"),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
