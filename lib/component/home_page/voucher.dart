import 'dart:async';
import 'package:flutter/material.dart';
import '../../screens/voucher_screen.dart';
import '../../services/api_service.dart';
import '../../models/voucher.dart';
import 'package:intl/intl.dart';

class VoucherScreen extends StatefulWidget {
  @override
  _VoucherScreenState createState() => _VoucherScreenState();
}

Color _getColorForIndex(int index) {
  const colors = [
    Color(0xFFB2DFDB), // Soft teal
    Color(0xFFFFF9C4), // Light yellow
    Color(0xFFC5CAE9), // Soft lavender
    Color(0xFFFFCCBC), // Light peach
    Color(0xFFD1C4E9), // Muted purple
  ];
  return colors[index % colors.length];
}

class _VoucherScreenState extends State<VoucherScreen> {
  late Future<List<Voucher>> _vouchersFuture;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _autoScrollTimer;
  Timer? _countdownTimer;

  List<Voucher> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _vouchersFuture = ApiService().fetchVouchers();
    _startAutoScroll();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _vouchers.isNotEmpty) {
        final nextPage = (_pageController.page ?? 0).toInt() + 1;
        if (nextPage < _vouchers.length) {
          _pageController.animateToPage(nextPage,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        } else {
          _pageController.animateToPage(0,
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh state every second to update countdown
      }
    });
  }

  String _formatCountdown(DateTime endTime) {
    final duration = endTime.difference(DateTime.now());
    if (duration.isNegative) return "Expired";
    return "${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 195, 228, 239), // Soft blue background
      body: FutureBuilder<List<Voucher>>(
        future: _vouchersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No vouchers available"));
          } else {
            _vouchers = snapshot.data!
                .where((voucher) => voucher.endTime.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.price.compareTo(b.price));

            if (_vouchers.isEmpty) {
              return Center(child: Text("No active vouchers available"));
            }

            return PageView.builder(
              controller: _pageController,
              itemCount: _vouchers.length,
              itemBuilder: (context, index) {
                final voucher = _vouchers[index];
                final color = _getColorForIndex(index);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VoucherPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withOpacity(0.8), color],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: voucher.imageUrl.isNotEmpty
                                        ? Container(
                                          color: Colors.white,
                                          child: Image.network(
                                              voucher.imageUrl,
                                              width: double.infinity,
                                              fit: BoxFit.contain,
                                              
                                            ),
                                        )
                                        : Container(
                                            color: Colors.grey[300],
                                            child:
                                                Center(child: Text("No Image")),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        voucher.productName,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Valid Until: ${DateFormat('MM/dd/yyyy').format(voucher.endTime)}",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Handle voucher claim
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF64B5F6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text("Claim Now"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${_formatCountdown(voucher.endTime)}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFD54F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                voucher.price == 0 ? "Free" : "₹${voucher.price}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
