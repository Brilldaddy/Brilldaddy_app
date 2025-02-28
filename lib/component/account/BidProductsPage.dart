import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BidProductsPage extends StatefulWidget {
  @override
  _BidProductsPageState createState() => _BidProductsPageState();
}

class _BidProductsPageState extends State<BidProductsPage> {
  Map<String, dynamic> groupedBids = {};
  Map<String, dynamic> voucherDetails = {};
  bool isLoading = true;
  String? errorMessage;
  
  final String serverUrl = "https://api.brilldaddy.com/api"; // Replace with your actual server URL
  String? userId;
  String? token;

  Future<void> loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    // Adjust the keys as per how you've stored them
    userId = prefs.getString('userId');
    token = prefs.getString('authToken');

    if (userId == null || token == null) {
      setState(() {
        errorMessage = "User not logged in.";
        isLoading = false;
      });
      return;
    }
    
    await fetchBids();
  }

  Future<void> fetchBids() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/user/bids/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          groupedBids = data;
        });

        // Fetch voucher details
        await fetchVoucherDetails(groupedBids.keys.toList());
      } else {
        throw Exception('Failed to load bids');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch data";
        isLoading = false;
      });
    }
  }

  Future<void> fetchVoucherDetails(List<String> voucherIds) async {
    try {
      final List<Future<http.Response>> requests = voucherIds.map((id) {
        return http.get(
          Uri.parse('$serverUrl/user/vouchers/$id'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }).toList();

      final responses = await Future.wait(requests);
      Map<String, dynamic> details = {};

      for (var response in responses) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is List && data.isNotEmpty) {
            details[data[0]['_id']] = data[0];
          }
        }
      }

      setState(() {
        voucherDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch voucher details";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserCredentials();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    if (groupedBids.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text("No bids found.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),

      appBar: AppBar(title: Text("Your Voucher Products",
        style: TextStyle(color: Colors.white),
      ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: groupedBids.entries.map((entry) {
            String voucherId = entry.key;
            List<dynamic> bids = entry.value;
            var details = voucherDetails[voucherId];

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details != null) ...[
                      Row(
                        children: [
                          Image.network(
                            details['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(details['product_name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Product Price: ₹${details['productPrice']}"),
                              Text("Voucher Price: ₹${details['price']}"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ] else
                      Text("Details not found for this voucher.", style: TextStyle(color: Colors.red)),

                    Text("Your Bids:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      children: bids.map((bid) {
                        final bidDate = DateTime.parse(bid['createdAt']);
                        return ListTile(
                          title: Text("₹${bid['bidAmount']}", style: TextStyle(color: Colors.green)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bid ID: ${bid['bidId']}"),
                              Text("Date: ${bidDate.toLocal().toString().split(' ')[0]}"),
                              Text("Time: ${bidDate.toLocal().toString().split(' ')[1]}"),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
