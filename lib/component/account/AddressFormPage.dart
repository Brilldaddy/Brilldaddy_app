import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/wishlist.dart';

class AddressFormPage extends StatefulWidget {
  final Map<String, dynamic>? address;
  final VoidCallback onRefresh;

  const AddressFormPage({Key? key, this.address, required this.onRefresh})
      : super(key: key);

  @override
  _AddressFormPageState createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController addressLineController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController flatNumberController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressTypeController = TextEditingController();

  String userId = '';
  String token = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    if (widget.address != null) {
      userNameController.text = widget.address!['userName'] ?? '';
      addressLineController.text = widget.address!['addressLine'] ?? '';
      pincodeController.text = widget.address!['pincode'] ?? '';
      streetController.text = widget.address!['street'] ?? '';
      stateController.text = widget.address!['state'] ?? '';
      flatNumberController.text = widget.address!['flatNumber'] ?? '';
      phoneNumberController.text =
          widget.address!['phoneNumber']?.toString() ?? '';
      addressTypeController.text = widget.address!['addressType'] ?? '';
    }
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      token = prefs.getString('authToken') ?? '';
    });
  }

  Future<void> submitAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> addressData = {
      'userId': userId, // Ensure userId is included
      'userName': userNameController.text,
      'addressLine': addressLineController.text,
      'pincode': pincodeController.text,
      'street': streetController.text,
      'state': stateController.text,
      'flatNumber': flatNumberController.text,
      'phoneNumber': int.tryParse(phoneNumberController.text) ?? 0,
      'addressType': addressTypeController.text,
    };

    try {
      http.Response response;
      if (widget.address != null) {
        String addressId = widget.address!['_id'].trim();
        print("Address id is: $addressId");
        response = await http.put(
          Uri.parse('$SERVER_URL/user/editAddress/$addressId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(addressData),
        );
      } else {
        response = await http.post(
          Uri.parse('$SERVER_URL/user/addAddress'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(addressData),
        );
      }

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.address != null
                ? 'Address updated successfully!'
                : 'Address added successfully!'),
          ),
        );
        // After a successful address addition:
        widget.onRefresh();
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operation failed: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error submitting address: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting address')),
      );
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    addressLineController.dispose();
    pincodeController.dispose();
    streetController.dispose();
    stateController.dispose();
    flatNumberController.dispose();
    phoneNumberController.dispose();
    addressTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: Text(widget.address != null ? 'Edit Address' : 'Add Address',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: userNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressLineController,
                      decoration: const InputDecoration(
                        labelText: 'Address Line',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter address line'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pincodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter pincode'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter street'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter state'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: flatNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Flat Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter flat number'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter phone number'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: addressTypeController.text.isNotEmpty
                          ? addressTypeController.text
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Address Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Home', 'Work', 'Others'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          addressTypeController.text = newValue ??
                              ''; // Update the controller with selected value
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select an address type'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submitAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        widget.address != null
                            ? 'Update Address'
                            : 'Add Address',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
