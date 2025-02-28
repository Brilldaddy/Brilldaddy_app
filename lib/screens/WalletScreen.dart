import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double? balance;
  List<dynamic> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        setState(() {
          error = "User not logged in.";
          isLoading = false;
        });
        return;
      }

      print("User ID: $userId");

      final String serverUrl =
          "https://api.brilldaddy.com/api/user/wallet/$userId";
      final response = await http.get(Uri.parse(serverUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          balance = (data['balance'] ?? 0.0).toDouble();
          // Reverse the list if necessary
          transactions = (data['transactions'] ?? []).reversed.toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error =
              "Failed to fetch wallet data. Status code: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      // Log the exception for debugging
      print("Error fetching data: $e");
      setState(() {
        error = "Error fetching data. Please try again later.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: const Text('Wallet',
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Card
                      Center(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Current Balance",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "₹${balance?.toStringAsFixed(2) ?? "0.00"}",
                                  style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Transactions Section
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: transactions.isEmpty
                            ? const Center(
                                child: Text(
                                  "No transaction history",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  bool isCredit =
                                      transaction['type'] == "credit";

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Wrap the left side with Expanded
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: isCredit
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                                  child: Icon(
                                                    isCredit
                                                        ? Icons.arrow_downward
                                                        : Icons.arrow_upward,
                                                    color: isCredit
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        transaction[
                                                                'description'] ??
                                                            '',
                                                        style:
                                                            const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.access_time,
                                                              size: 14,
                                                              color:
                                                                  Colors.grey),
                                                          const SizedBox(
                                                              width: 4),
                                                          Flexible(
                                                            child: Text(
                                                              transaction[
                                                                      'date'] ??
                                                                  '',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                          Text(
                                            "${isCredit ? "+" : "-"} ₹${(transaction['amount'] as num).toDouble().toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isCredit
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
