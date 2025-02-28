import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/cart.dart';
import 'payment_success.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String serverUrl;
  final String userId;
  final double total;
  final List<dynamic> cartItems;
  final Map<String, dynamic> selectedAddress;
  final String paymentMethod;
  final Map<String, dynamic> user;

  PaymentMethodScreen({
    required this.serverUrl,
    required this.userId,
    required this.total,
    required this.cartItems,
    required this.selectedAddress,
    required this.paymentMethod,
    required this.user,
  });

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
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

  Future<void> handlePlaceOrder() async {
    if (widget.selectedAddress.isEmpty || widget.paymentMethod.isEmpty) {
      _showAlert(
          "Please select both an address and a payment method before placing the order.");
      return;
    }

    if (widget.paymentMethod == "Razorpay") {
      try {
        var response = await http.post(
          Uri.parse("https://api.brilldaddy.com/api/user/checkout/createOrder"),
          body: jsonEncode({
            "amount": widget.total * 100, // Convert to paise
            "receipt": "receipt_${DateTime.now().millisecondsSinceEpoch}",
          }),
          headers: {"Content-Type": "application/json"},
        );

        var responseData = jsonDecode(response.body);
        print("Response Data: $responseData");
        print("Total Amount: ${widget.total}");
        print("Converted Amount (Paise): ${widget.total * 100}");

        if (response.statusCode == 200 && responseData['success']) {
          // Convert cart items to a string format for notes
          List<String> productDetails = widget.cartItems.map((item) {
            return "${item['product']['name']} (x${item['quantity']}) - ₹${item['price'] * item['quantity']}";
          }).toList();

          var options = {
            'key':
                "rzp_test_yjMX4hSQ75uCRn", // Replace with actual Razorpay Key ID
            'amount': widget.total,
            'currency': responseData['order']['currency'],
            'name': "BRILLDADDY ECOMMERCE PVT LTD.",
            'description': "Order Payment",
            'order_id': responseData['order']['id'],
            'prefill': {
              'name': widget.user['name'],
              'email': widget.user['email'],
              'contact': widget.user['phone'],
            },
            'notes': {
              'address': widget.selectedAddress['addressLine'],
              'products': productDetails.join(", "), // Add product details
            },
            'theme': {
              'color': "#3399cc",
            }
          };

          _razorpay.open(options);
        } else {
          _showAlert("Error while creating order. Please try again.");
        }
      } catch (e) {
        _showAlert("Payment failed: $e");
      }
    } else {
      // Handle Cash on Delivery (COD)
      await _placeOrder(paid: false, orderStatus: "Pending");
    }
  }

  Future<void> _placeOrder(
      {required bool paid, required String orderStatus}) async {
    try {
      var response = await http.post(
        Uri.parse("https://api.brilldaddy.com/api/user/checkout/placeorder"),
        body: jsonEncode({
          "userId": widget.userId,
          "amount": widget.total,
          "cartItems": widget.cartItems,
          "selectedAddressId": widget.selectedAddress['_id'],
          "paymentMethod": widget.paymentMethod,
          "paid": paid,
          "orderStatus": orderStatus,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              cartItems: widget.cartItems
                  .map((item) => CartItem.fromJson(item))
                  .toList(),
              userId: widget.userId,
            ),
          ),
        );
      } else {
        _showAlert("Order placement failed. Please try again.");
      }
    } catch (e) {
      _showAlert("Error placing order: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      var verifyResponse = await http.post(
        Uri.parse("https://api.brilldaddy.com/api/user/checkout/verifyPayment"),
        body: jsonEncode({
          "razorpay_order_id": response.orderId,
          "razorpay_payment_id": response.paymentId,
          "razorpay_signature": response.signature,
        }),
        headers: {"Content-Type": "application/json"},
      );

      var verifyData = jsonDecode(verifyResponse.body);
      if (verifyData['success']) {
        await _placeOrder(paid: true, orderStatus: "Paid");
      } else {
        _showAlert("Payment verification failed. Please try again.");
      }
    } catch (e) {
      _showAlert("Error verifying payment: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showAlert("Payment failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showAlert("External wallet selected: ${response.walletName}");
  }

  void _showAlert(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: Text("Payment Method", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Shipping Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${widget.selectedAddress['addressLine'] ?? ''}, "
                "${widget.selectedAddress['street'] ?? ''}, "
                "${widget.selectedAddress['state'] ?? ''} - ${widget.selectedAddress['pincode'] ?? ''}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 20),
            Text("Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  var item = widget.cartItems[index];

                  if (item is! CartItem) {
                    item = CartItem.fromJson(
                        item); // Convert JSON map to CartItem object
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(item.product.name,
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold)), // Access product name
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.product.sizes != null)
                            Text("Quantity: ${item.quantity}"),
                          Text("Price: ₹${item.price * item.quantity}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Divider(),

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Amount:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${widget.total}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handlePlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Proceed to Payment",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
