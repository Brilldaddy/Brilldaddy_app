import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../component/account/AddressFormPage.dart';
import '../services/wishlist.dart';
import 'payment_gateway.dart';
import 'payment_success.dart';

class AddressSelectionScreen extends StatefulWidget {
  final double totalAmount;
  final List<dynamic> cartItems;

  AddressSelectionScreen({required this.totalAmount, required this.cartItems});

  @override
  _AddressSelectionScreenState createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<dynamic> addresses = [];
  bool isLoading = true;
  String? selectedAddressId;
  String? authToken;
  String token = '';

  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserData().then((_) {
      fetchAddresses();
    });
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      token = prefs.getString('authToken') ?? '';
    });
  }

  Future<void> fetchAddresses() async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    print("Shipping address page uid: $userId");
    print("Shipping address page token: $token");

    try {
      final response = await http.get(
        Uri.parse('$SERVER_URL/user/addresses/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          addresses = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch addresses: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching addresses')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void proceedToPayment() {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address")),
      );
      return;
    }

    // Find the selected address details
    final selectedAddress = addresses.firstWhere(
      (address) => address['_id'] == selectedAddressId,
      orElse: () => null,
    );

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid address selected.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          total: widget.totalAmount,
          cartItems: widget.cartItems,
          selectedAddress: selectedAddress,
          serverUrl: SERVER_URL,
          userId: userId ?? '',
          paymentMethod: 'Razorpay',
          user: {},
        ),
      ),
    );
  }

  Future<void> navigateToAddAddress() async {
    // Navigate to AddAddressScreen and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddressFormPage(
                onRefresh: () {
                  fetchAddresses();
                },
              )),
    );
    // If address added successfully, refresh the addresses list
    // if (result == true) {
    //   fetchAddresses();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: Text(
          "Select Address",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: "Add Address",
            onPressed: navigateToAddAddress,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(child: Text("No addresses found. Add one!"))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: address['_id'],
                              groupValue: selectedAddressId,
                              onChanged: (value) {
                                setState(() {
                                  selectedAddressId = value;
                                });
                              },
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Text(
                                    address['userName'] ?? 'Name',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Full address
                                  Text(
                                    "${address['flatNumber']}, ${address['street']}, ${address['state']}, ${address['pincode']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),

                                  SizedBox(height: 8),
                                  // Address Type
                                  Text(
                                    "Type: ${address['addressType']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ElevatedButton(
          onPressed: proceedToPayment,
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
    );
  }
}
