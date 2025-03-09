import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken')?.trim();

    if (authToken == null || authToken.isEmpty) {
      _showAlert("Authentication failed. Please log in again.");
      return;
    }

    if (widget.selectedAddress.isEmpty || widget.paymentMethod.isEmpty) {
      _showAlert(
          "Please select both an address and a payment method before placing the order.");
      return;
    }

    int amountInPaise =
        (widget.total).toInt(); // ✅ Correct, convert INR to paise

    print("Total in INR: ${widget.total}, Amount in paise: $amountInPaise");

    if (amountInPaise <= 0) {
      _showAlert("Invalid order amount. Please check your cart.");
      return;
    }

    if (widget.paymentMethod == "Razorpay") {
      try {
        print("Amount being sent to Razorpay: $amountInPaise paise");
        print("${widget.serverUrl}/user/checkout/createOrder");
        var response = await http.post(
          Uri.parse("${widget.serverUrl}/user/checkout/createOrder"),
          body: jsonEncode({
            "amount": amountInPaise, // ✅ Ensure amount is in paise
            "receipt": "receipt_${DateTime.now().millisecondsSinceEpoch}",
          }),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $authToken',
          },
        );
        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          if (responseData['success'] && responseData['order'] != null) {
            var options = {
              'key': "rzp_test_yjMX4hSQ75uCRn",
              'amount': amountInPaise, // ✅ Ensure amount is in paise
              'currency': 'INR',
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
                'products': widget.cartItems.map((item) {
                  if (item is CartItem) {
                    return "${item.product.name} (x${item.quantity})";
                  } else if (item is Map<String, dynamic>) {
                    return "${item['product']['name']} (x${item['quantity']})";
                  }
                }).join(", "),
              },
              'theme': {'color': "#3399cc"},
            };

            _razorpay.open(options);
          } else {
            _showAlert(
                "Error while creating order. Server response: ${response.body}");
          }
        } else if (response.statusCode == 500) {
          _showAlert(
              "Server error occurred. Please try again later or contact support.");
          await _placeOrder(paid: false, orderStatus: "Pending");
        } else {
          var responseData = jsonDecode(response.body);
          _showAlert(
              "Payment initialization error: ${responseData['message']}");
        }
      } catch (e) {
        _showAlert("Payment initialization error: $e");
        await _placeOrder(paid: false, orderStatus: "Pending");
      }
    } else {
      await _placeOrder(paid: false, orderStatus: "Pending");
    }
  }

  Future<void> _placeOrder(
      {required bool paid, required String orderStatus}) async {
    int amountInPaise = (widget.total).toInt();

    try {

      var cartItemsJson = widget.cartItems.map((item) {
        return {
          "productId": {
            "averageRating": item.product.averageRating ?? 0,
            "_id":  item.product.id ?? '',
            "name": item.product.name ?? '',
          },
          "price": item.price ?? 0,
          "quantity": item.quantity ?? 1,
          "size": item.size ?? 'N/A',
          "walletDiscountAmount": item.walletDiscountAmount ?? 0,
          "walletDiscountApplied": item.walletDiscountApplied ?? false,
          "_id": '',
        };
      }).toList();

      var reqBody = {
        "userId": widget.userId,
        "total": amountInPaise,
        "cartItems":cartItemsJson,
        "orderStatus": orderStatus,
        "paid": paid,
        "paymentMethod": widget.paymentMethod,
        "selectedAddressId": widget.selectedAddress['_id'],
      };


      var response = await http.post(
        Uri.parse("${widget.serverUrl}/user/checkout/placeorder"),
        body: jsonEncode(reqBody),
        headers: {"Content-Type": "application/json"},
      );
      print('status code is: ${response.statusCode}');
      print('Response is: ${response.body}');

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              cartItems: widget.cartItems.map((item) {
                if (item is Map<String, dynamic>) {
                  return CartItem.fromJson(item);
                } else if (item is CartItem) {
                  return item;
                } else {
                  throw Exception(
                      "Invalid cart item type: ${item.runtimeType}");
                }
              }).toList(),
              userId: widget.userId,
            ),
          ),
        );
      } else {
        print("Order placement failed. Response: ${response.body}");
        _showAlert("Order placement failed. Response: ${response.body}");
      }
    } catch (e) {
      print("Error placing order: $e");
      _showAlert("Error placing order: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      var verifyResponse = await http.post(
        Uri.parse("${widget.serverUrl}/user/checkout/verifyPayment"),
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
        _showAlert(
            "Payment verification failed. Response: ${verifyResponse.body}");
      }
    } catch (e) {
      _showAlert("Error verifying payment: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showAlert("Payment failed: ${response.message} (Code: ${response.code})");
    _placeOrder(paid: false, orderStatus: "Pending");
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
        padding: const EdgeInsets.all(8.0),
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
                    item = CartItem.fromJson(item as Map<String, dynamic>);
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(item.product.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
