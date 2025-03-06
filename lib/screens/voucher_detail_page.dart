import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voucher.dart';
import '../models/winner.dart';
import '../services/voucher_winner.dart';
import 'voucher_screen.dart';

class EventDetailPage extends StatefulWidget {
  final Voucher voucher;
  final String userId;

  const EventDetailPage({
    Key? key,
    required this.voucher,
    required this.userId,
  }) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final VoucherApiService voucherApiService = VoucherApiService();
  List<Winner> winners = [];
  double bidAmount = 0.1;
  String bidId = "";
  String userId = "";
  String errorMessage = "";
  String token = "";
  bool confirmEnabled = false;
  final double minBidAmount = 0.1;
  late TextEditingController _bidController;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchWinners();
    _bidController = TextEditingController(text: bidAmount.toStringAsFixed(1));
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      token = prefs.getString('authToken') ?? '';
    });
  }

  Future<void> fetchWinners() async {
    try {
      List<Winner> fetchedWinners =
          await voucherApiService.fetchWinners(widget.voucher.id);
      setState(() {
        winners = fetchedWinners;
      });
    } catch (e) {
      print(e);
    }
  }

  void handleBid() {
    if (bidAmount < 0.1) {
      setState(() {
        errorMessage = "Bid amount must be between 0.1 and \$maxBidAmount";
      });
      return;
    }
    final uniqueId = "BID-" + Random().nextInt(1000000).toString();
    setState(() {
      bidId = uniqueId;
      confirmEnabled = true;
      errorMessage = "";
    });
  }

  void updateBidAmount(double value) {
    setState(() {
      bidAmount = double.parse(value.toStringAsFixed(1));
      _bidController.text = bidAmount.toStringAsFixed(1);
    });
  }

  Future<void> handleConfirm() async {
    if (token.isEmpty) {
      setState(() {
        errorMessage = "User not authenticated. Please log in again.";
      });
      return;
    }

    try {
      bool success = await voucherApiService.confirmBid(
          widget.userId, widget.voucher.id, bidAmount, bidId);

      if (success) {
        // Navigate to VoucherPage after successful submission
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VoucherPage()),
        );
      } else {
        setState(() {
          errorMessage = "Failed to submit bid. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('500')) {
          errorMessage = "Server error occurred. Please try again later.";
        } else {
          errorMessage = "An error occurred: ${e.toString()}";
        }
      });
    }
  }

  Widget _buildBidSection() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Place Your Value",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Decrease Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (bidAmount > minBidAmount) {
                        bidAmount =
                            double.parse((bidAmount - 0.1).toStringAsFixed(1));
                      }
                    });
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),

                // TextField with Decimal Control
                Expanded(
                  child: TextField(
                    controller: _bidController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Amount (₹)",
                    ),
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      if (parsedValue != null && parsedValue >= minBidAmount) {
                        setState(() {
                          bidAmount = parsedValue;
                        });
                      }
                    },
                  ),
                ),

                // Increase Button
                IconButton(
                  onPressed: () {
                    setState(() {
                      bidAmount =
                          double.parse((bidAmount + 0.1).toStringAsFixed(1));
                    });
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Aligning Submit Button to Right
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: handleBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ),

            if (bidId.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Unique ID: $bidId",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: confirmEnabled ? handleConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnersSection() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: winners.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Winners List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: winners.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final winner = winners[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.star, color: Colors.orange),
                          title: Text(
                            winner.prize,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🎟️ ID: ${winner.bidId}",
                                  style: const TextStyle(fontSize: 14)),
                              Text("👤 Name: ${winner.username}",
                                  style: const TextStyle(fontSize: 14)),
                              Text("📍 State: ${winner.state}",
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            : Column(
                children: [
                  Text(
                    "🏆 Winners 🏆",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No winners selected yet!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVoucherCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Voucher image section with a gradient overlay
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                widget.voucher.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.voucher.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Text("No Image")),
                      ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Voucher details section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.voucher.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.voucher.details,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title:
            const Text("Event Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildVoucherCard(),
              _buildBidSection(),
            ],
          ),
        ),
      ),
    );
  }
}
