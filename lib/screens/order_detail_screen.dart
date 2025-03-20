import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:pdf/pdf.dart';
import 'package:brilldaddy/services/order_detial_service.dart';
import 'package:brilldaddy/component/order_detials/cancel_order_dialog.dart';
import 'package:brilldaddy/component/order_detials/return_order_dialog.dart';
import 'package:brilldaddy/component/order_detials/invoice_generator.dart';
import 'package:brilldaddy/component/order_detials/order_status_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String id;
  final String productId;
  final String orderStatus; // Add this line to accept orderStatus

  OrderDetailsScreen({
    required this.id,
    required this.productId,
    required this.orderStatus, // Add this line to accept orderStatus
  });

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, String> imageUrls = {};
  Map<String, dynamic>? address;
  Map<String, dynamic>? order;
  bool isCancelButtonDisabled = false;
  bool isOrderCancelled = false;
  TextEditingController bankAccountController = TextEditingController();
  TextEditingController otherReasonController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController holderNameController = TextEditingController();
  DateTime? deliveryDate;
  bool isReturnEligible = false;

  @override
  void initState() {
    super.initState();
    print("Product id: ${widget.productId}");
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final data = await OrderDetailService.fetchOrderDetails(widget.id);
      print("Order Details: $data"); // Debugging

      setState(() {
        order = data;
        String status = widget.orderStatus; // Use the passed orderStatus

        isOrderCancelled = status == 'Cancelled';
        isCancelButtonDisabled = isOrderCancelled || status == 'Delivered';
        // Assign Address Directly from 'selectedAddressId'
        if (data.containsKey('selectedAddressId') &&
            data['selectedAddressId'] != null) {
          address = data['selectedAddressId']; // No need to fetch separately
        }
        if (data.containsKey('cartItems') && data['cartItems'].isNotEmpty) {
          fetchImages([data]); // Pass the order as a list
        }

        // Extract delivery date
        if (data['deliveredAt'] != null) {
          deliveryDate = DateTime.parse(data['deliveredAt']);
          final now = DateTime.now();
          final difference = now.difference(deliveryDate!).inDays;
          isReturnEligible = difference <= 7;
          print("Delivery Date: $deliveryDate");
          print("Days Difference: $difference");
          print("Is Return Eligible: $isReturnEligible");
        }
        print("Order Status: $status");
        print("Is Cancel Button Disabled: $isCancelButtonDisabled");
        print("Is return Button Disabled: $isReturnEligible");

        // Assign bank details if present
        final bankDetails = data['bankDetails'] ?? {};
        bankAccountController.text =
            (bankDetails['accountNumber'] ?? "").toString();
        ifscController.text = (bankDetails['ifscCode'] ?? "").toString();
        branchController.text = (bankDetails['branch'] ?? "").toString();
        holderNameController.text =
            (bankDetails['accountHolderName'] ?? "").toString();
      });
    } catch (e) {
      print("Error fetching order details: $e");
    }
  }

  Future<void> fetchImages(List orders) async {
    Map<String, String> imageUrlsMap = {};
    for (var order in orders) {
      for (var item in order['cartItems']) {
        String imageId = item['productId']['images'][0] is int
            ? item['productId']['images'][0].toString()
            : item['productId']['images'][0];

        final imageUrl = await OrderDetailService.fetchImageUrl(imageId);
        imageUrlsMap[imageId] = imageUrl;
      }
    }
    if (!mounted) return;
    setState(() => imageUrls = imageUrlsMap);
  }

  Future<void> generateInvoice() async {
    try {
      final invoiceGenerator = InvoiceGenerator();
      final orderData =
          await OrderDetailService.fetchOrderDetailsForInvoice(widget.id);
      final file =
          await invoiceGenerator.generateAndSaveInvoice(widget.id, orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Invoice downloaded successfully to ${file.path}.")),
      );
    } catch (e) {
      print("Error generating PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating invoice.")),
      );
    }
  }

  Future<void> cancelOrder() async {
    try {
      final success = await OrderDetailService.cancelOrder(
        widget.id,
        order!['userId'].toString(),
        widget.productId,
        otherReasonController.text,
        {
          "accountNumber": bankAccountController.text,
          "ifscCode": ifscController.text,
          "branch": branchController.text,
          "accountHolderName": holderNameController.text,
        },
        order!,
      );

      if (success) {
        setState(() {
          isOrderCancelled = true;
          isCancelButtonDisabled = true;
          order!['orderStatus'] = 'Cancelled';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order cancelled successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel order.")),
        );
      }
    } catch (e) {
      print("Error cancelling order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling order.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Order Details")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: Text("Order Details ", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary",
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Order ID: ${widget.id}", style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            ...order!['cartItems']
                .where((item) => item['productId']['_id'] == widget.productId)
                .map<Widget>((item) {
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.network(
                          imageUrls[item['productId']['images'][0]] ??
                              'https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=1024x1024&w=is&k=20&c=5aen6wD1rsiMZSaVeJ9BWM4GGh5LE_9h97haNpUQN5I=',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover),
                      title: Text(item['productId']['name'],
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      subtitle: Text("₹${item['price']} x ${item['quantity']}",
                          style: GoogleFonts.poppins(fontSize: 14)),
                      trailing: Text(
                        "Total: ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                        style: GoogleFonts.robotoMono(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    OrderStatusWidget(order: item)
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Text("Shipping Address",
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            address != null && address!.isNotEmpty
                ? Text(
                    "${address!['street'] ?? 'N/A'}, "
                    "${address!['city'] ?? 'N/A'}, "
                    "${address!['state'] ?? 'N/A'} - "
                    "${address!['zip'] ?? 'N/A'}",
                    style: GoogleFonts.poppins(fontSize: 16),
                  )
                : Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (order!['orderStatus'] == 'Delivered' && isReturnEligible)
                  ElevatedButton.icon(
                    onPressed: () {
                      showReturnOrderPopup();
                      print("Returning order...");
                    },
                    icon: Icon(Icons.assignment_return, color: Colors.white),
                    label: Text("Return Order",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.all(12),
                    ),
                  )
                else if (order!['orderStatus'] != 'Delivered' &&
                    !isCancelButtonDisabled)
                  ElevatedButton.icon(
                    onPressed: () {
                      showCancelOrderPopup();
                      print("Cancelling order...");
                    },
                    icon: Icon(Icons.cancel, color: Colors.white),
                    label: Text("Cancel Order",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: generateInvoice,
                  icon: Icon(Icons.download, color: Colors.white),
                  label: Text("Download Invoice",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showCancelOrderPopup() {
    showDialog(
      context: context,
      builder: (context) => CancelOrderDialog(
        orderId: widget.id,
        productId: widget.productId,
        userId: order!['userId'].toString(),
        cartItems: order!['cartItems'],
        orderDetails: order!,
        bankAccountController: bankAccountController,
        ifscController: ifscController,
        branchController: branchController,
        holderNameController: holderNameController,
        onOrderCancelled: (bool status) {
          setState(() {
            isOrderCancelled = status;
            isCancelButtonDisabled = status;
            order!['orderStatus'] = 'Cancelled';
          });
        },
      ),
    );
  }

  void showReturnOrderPopup() {
    showDialog(
      context: context,
      builder: (context) => ReturnOrderDialog(
        orderId: widget.id,
        productId: widget.productId,
        userId: order!['userId'].toString(),
        cartItems: order!['cartItems'],
        orderDetails: order!,
        bankAccountController: bankAccountController,
        ifscController: ifscController,
        branchController: branchController,
        holderNameController: holderNameController,
        onOrderReturned: (bool status) {
          setState(() {
            isOrderCancelled = status;
            isCancelButtonDisabled = status;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    bankAccountController.dispose();
    otherReasonController.dispose();
    ifscController.dispose();
    branchController.dispose();
    holderNameController.dispose();
    super.dispose();
  }
}
