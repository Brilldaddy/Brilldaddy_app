import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../component/home_page/nav_bar.dart' as cost;

import '../component/home_page/drawer.dart';
import '../component/voucher_page/winner_page.dart';
import '../models/voucher.dart';
import '../services/api_service.dart';
import 'voucher_detail_page.dart';

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  List<dynamic> vouchers = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> winners = [];
  late Future<List<Voucher>> _vouchersFuture;
  Razorpay? _razorpay;
  String userId = "";
  var _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    loadUserId();
    _vouchersFuture = ApiService().fetchVouchers();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful")),
    );

    // Navigate to the voucher detail page after successful payment
    if (_selectedVoucher != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailPage(
            voucher: _selectedVoucher, // Convert Map to Voucher object
            userId: userId,
          ),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleClaimVoucher(Voucher voucher) {
    setState(() {
      _selectedVoucher = voucher;
    });

    if (voucher.price == 0) {
      // Navigate directly for free vouchers
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailPage(
            voucher: _selectedVoucher,
            userId: userId,
          ),
        ),
      );
    } else {
      // Handle Razorpay payment
      var options = {
        'key': 'rzp_test_yjMX4hSQ75uCRn',
        'amount': voucher.price * 100,
        'currency': 'INR',
        'name': 'BrillDaddy Ecommerce Pvt Ltd.',
        'description': 'Voucher: ${voucher.productName}',
        'prefill': {'contact': '1234567890', 'email': 'user@example.com'},
      };

      try {
        _razorpay!.open(options);
      } catch (e) {
        print("Error opening Razorpay: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment initialization failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      key: _scaffoldKey,
      appBar: cost.NavigationBar(scaffoldKey: _scaffoldKey),
      endDrawer: const DrawerMenu(),
      body: FutureBuilder<List<Voucher>>(
        future: _vouchersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No vouchers available"));
          }

          final vouchers = snapshot.data!
              .where((voucher) => voucher.endTime.isAfter(DateTime.now()))
              .toList()
            ..sort((a, b) => a.price.compareTo(b.price));

          if (vouchers.isEmpty) {
            return Center(child: Text("No active vouchers available"));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              WinnersSection(winners: Future.value([])),
              ...vouchers.map((voucher) => _buildVoucherCard(voucher)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final color = [
      Color(0xFFB2DFDB),
      Color(0xFFE6EE9C),
      Color(0xFFFFCCBC),
      Color(0xFFB3E5FC),
      Color(0xFFD7CCC8)
    ][voucher.id.hashCode % 5];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    child: voucher.imageUrl.isNotEmpty
                        ? Image.network(
                            voucher.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          )
                        : Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Center(child: Text("No Image")),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          onPressed: () => _handleClaimVoucher(voucher),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
              child: CountdownWidget(endTime: voucher.endTime),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  voucher.price == 0 ? "Free" : "₹${voucher.price}",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}

class CountdownWidget extends StatefulWidget {
  final DateTime endTime;
  const CountdownWidget({Key? key, required this.endTime}) : super(key: key);

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.endTime.difference(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _duration = widget.endTime.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Expired";
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return "${days}d ${hours}h ${minutes}m ${seconds}s";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formatDuration(_duration),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
