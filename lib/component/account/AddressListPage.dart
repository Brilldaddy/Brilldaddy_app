import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/wishlist.dart';
import 'AddressFormPage.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({Key? key}) : super(key: key);

  @override
  _AddressListPageState createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<dynamic> addresses = [];
  String userId = '';
  String token = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      token = prefs.getString('authToken') ?? '';
        print("UserId on address page: $userId");
      print("Token: $token");
    });
    if (userId.isNotEmpty && token.isNotEmpty) {
      fetchAddresses();
    }
  }

  Future<void> fetchAddresses() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$SERVER_URL/user/addresses/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          addresses = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch addresses: ${response.statusCode}')),
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

  Future<void> deleteAddress(String addressId) async {
  try {
    // Adjust the URL based on your API. Here we assume userId is not in the URL.
    final url = '$SERVER_URL/user/deleteAddress/$addressId';
    print("Deleting address using URL: $url");
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // Pass userId in body if required by API
      body: json.encode({'userId': userId}),
    );
    print("Delete response: ${response.statusCode} - ${response.body}");
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted successfully')),
      );
      fetchAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address: ${response.statusCode}\n${response.body}')),
      );
    }
  } catch (e) {
    print('Error deleting address: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error deleting address')),
    );
  }
}


  void navigateToAddressForm({Map<String, dynamic>? address}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormPage(
          address: address,
          onRefresh: fetchAddresses,
        ),
      ),
    );
  }

  Widget buildAddressCard(Map<String, dynamic> address) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(address['userName'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address['addressLine'] ?? ''),
            Text('Pincode: ${address['pincode']}'),
            Text('Phone: ${address['phoneNumber']}'),
            Text('Type: ${address['addressType']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () => navigateToAddressForm(address: address),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => deleteAddress(address['_id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),

      appBar: AppBar(
        title: const Text('My Addresses',
          style: TextStyle(color: Colors.white),
          ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddressForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? const Center(child: Text('No addresses found.'))
              : ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    return buildAddressCard(addresses[index]);
                  },
                ),
    );
  }
}
