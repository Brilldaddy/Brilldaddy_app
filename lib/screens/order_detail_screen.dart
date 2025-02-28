import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

const SERVER_URL = "https://api.brilldaddy.com/api";

class OrderDetailsScreen extends StatefulWidget {
  final String id;
  final String productId;

  OrderDetailsScreen({
    required this.id,
    required this.productId,
  });

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? order;
  Map<String, String> imageUrls = {};
  bool isCancelButtonDisabled = false;
  bool isOrderCancelled = false;
  bool returnButtonDisabled = false;
  String selectedReason = "";
  TextEditingController bankAccountController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController holderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
  try {
    final response = await http.get(Uri.parse('$SERVER_URL/user/order/${widget.id}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        order = data;
        isOrderCancelled = data['status'] == 'Cancelled';
        isCancelButtonDisabled = isOrderCancelled || data['status'] == 'Delivered';

        // Ensure all values are converted to strings
       bankAccountController.text = (data['bankDetails']['accountNumber'] ?? "").toString();
ifscController.text = (data['bankDetails']['ifscCode'] ?? "").toString();
branchController.text = (data['bankDetails']['branch'] ?? "").toString();
holderNameController.text = (data['bankDetails']['accountHolderName'] ?? "").toString();

      });
    }
  } catch (e) {
    print("Error: $e");
  }
}


  Future<void> handleCancelOrder() async {
    if (!validateBankDetails()) return;

    try {
      final response = await http.put(
        Uri.parse('$SERVER_URL/admin/cancel-order/${order!['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": order!['userId'],
          "orderId": order!['_id'],
          "productId": widget.productId,
          "cancelReason": selectedReason,
          "bankDetails": {
            "accountNumber": bankAccountController.text,
            "ifscCode": ifscController.text,
            "branch": branchController.text,
            "accountHolderName": holderNameController.text
          }
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isOrderCancelled = true;
          isCancelButtonDisabled = true;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  bool validateBankDetails() {
    if (bankAccountController.text.isEmpty ||
        ifscController.text.isEmpty ||
        branchController.text.isEmpty ||
        holderNameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Fill in all bank details")));
      return false;
    }
    return true;
  }

  Future<void> generateInvoice() async {
    try {
      final pdf = pdfLib.Document();
      pdf.addPage(
        pdfLib.Page(
          build: (context) => pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
            children: [
              pdfLib.Text("Invoice",
                  style: pdfLib.TextStyle(
                      fontSize: 24, fontWeight: pdfLib.FontWeight.bold)),
              pdfLib.Text("Order ID: ${widget.id}",
                  style: pdfLib.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Invoice_${widget.id}.pdf');
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error generating PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text("Order Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: order!['cartItems'].length,
              itemBuilder: (context, index) {
                final item = order!['cartItems'][index];
                return Card(
                  child: ListTile(
                    title: Text(item['productId']['name']),
                    subtitle: Text("₹${item['price']} x ${item['quantity']}"),
                    trailing: Text(
                        "Total: ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: isCancelButtonDisabled ? null : handleCancelOrder,
              child: Text("Cancel Order"),
            ),
            ElevatedButton(
              onPressed: generateInvoice,
              child: Text("Download Invoice"),
            ),
          ],
        ),
      ),
    );
  }
}
