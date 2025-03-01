import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define Server URL
const String SERVERURL = "https://api.brilldaddy.com/api";

// Winner Model
class Winner {
  final String id;
  final String voucherId; // Store the voucherId
  final double winningAmount;
  final String wonAt;

  // Voucher details fields
  String productName;
  String voucherName;
  String imageUrl;
  String details;

  Winner({
    required this.id,
    required this.voucherId,
    required this.winningAmount,
    required this.wonAt,
    this.productName = 'N/A',
    this.voucherName = 'N/A',
    this.imageUrl = 'https://via.placeholder.com/150',
    this.details = 'No additional details available',
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      id: json['_id'] ?? '',
      voucherId: json['voucherId'] ?? '',
      winningAmount: (json['winningAmount'] as num).toDouble(),
      wonAt: json['wonAt'] ?? '',
    );
  }
}

// Voucher Model
class Voucher {
  final String productName;
  final String voucherName;
  final String imageUrl;
  final String details;

  Voucher({
    required this.productName,
    required this.voucherName,
    required this.imageUrl,
    required this.details,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      productName: json['product_name'] ?? 'N/A',
      voucherName: json['voucher_name'] ?? 'N/A',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      details: json['details'] ?? 'No additional details available',
    );
  }
}

Future<Voucher> fetchVoucher(String voucherId, String token) async {
  final response = await http.get(
    Uri.parse('$SERVERURL/user/vouchers/$voucherId'),
    headers: {'Authorization': 'Bearer $token'},
  );
 

  if (response.statusCode == 200) {
    // Parse the response as a List first, then extract the first element.
    List<dynamic> dataList = jsonDecode(response.body);
    if (dataList.isNotEmpty) {
      Map<String, dynamic> data = dataList[0];
      return Voucher.fromJson(data);
    } else {
      throw Exception('No voucher data found');
    }
  } else {
    throw Exception('Failed to load voucher details');
  }
}

// Fetch Winner Details Function
Future<List<Winner>> fetchWinners(String userId, String token) async {
  try {
    final response = await http.get(
      Uri.parse('$SERVERURL/user/winners/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
 

    if (response.statusCode == 200) {
      List<dynamic> winnersData = jsonDecode(response.body);
      List<Winner> winners =
          winnersData.map((winner) => Winner.fromJson(winner)).toList();

      // For each winner, fetch the voucher details
      for (Winner winner in winners) {
        try {
          Voucher voucher = await fetchVoucher(winner.voucherId, token);
          print(
              "Voucher fetched for winner ${winner.id}: ${voucher.productName}, ${voucher.imageUrl}");
          winner.productName = voucher.productName;
          winner.voucherName = voucher.voucherName;
          winner.imageUrl = voucher.imageUrl;
          winner.details = voucher.details;
        } catch (e) {
          print("Error fetching voucher for winner ${winner.id}: $e");
        }
      }
      return winners;
    } else {
      throw Exception('Failed to load winners');
    }
  } catch (e) {
    throw Exception('Error fetching winners: $e');
  }
}

// WinnerAlbumPage Widget using shared_preferences
class WinnerAlbumPage extends StatefulWidget {
  @override
  _WinnerAlbumPageState createState() => _WinnerAlbumPageState();
}

class _WinnerAlbumPageState extends State<WinnerAlbumPage> {
  late Future<List<Winner>> _winnerFuture;
  String? _userId;
  String? _token;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from shared_preferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("userId: ${prefs.getString('userId')}");
    print("token: ${prefs.getString('authToken')}");

    setState(() {
      _userId = prefs.getString('userId');
      _token = prefs.getString('authToken');
      _isLoggedIn = _userId != null && _token != null;
    });

    if (_isLoggedIn) {
      setState(() {
        _winnerFuture = fetchWinners(_userId!, _token!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(title: Text("Winner Album",
      style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.blueAccent,
      centerTitle: true,),
      body: _isLoggedIn
          ? FutureBuilder<List<Winner>>(
              future: _winnerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No winning items found."));
                }

                List<Winner> winners = snapshot.data!;

                return ListView.builder(
                  itemCount: winners.length,
                  itemBuilder: (context, index) {
                    Winner winner = winners[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          winner.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image);
                          },
                        ),
                        title: Text(
                          "🎉 Congratulations! You've Won",
                          style: TextStyle(
                            fontSize: 15, // increase size
                            fontWeight: FontWeight.bold, // make it bold
                            color: Colors
                                .deepPurple, // change to a professional color
                            letterSpacing:
                                1.2, // slightly increased letter spacing
                          ),
                        ),
                        subtitle: Builder(builder: (context) {
                          DateTime wonAtDateTime = DateTime.parse(winner.wonAt);
                          String formattedDate =
                              DateFormat.yMd().format(wonAtDateTime);
                          DateFormat.Hm().format(wonAtDateTime);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🏷 Product: ${winner.productName}"),
                              Text("📅 Date: $formattedDate"),
                              Text(
                                  "💰 Winning Amount: ${winner.winningAmount}"),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                );
              },
            )
          : Center(child: Text("User not logged in.")),
    );
  }
}
