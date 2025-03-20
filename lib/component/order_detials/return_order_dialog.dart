import 'package:flutter/material.dart';
import '../../services/order_detial_service.dart';

class ReturnOrderDialog extends StatefulWidget {
  final String orderId;
  final String productId;
  final String userId;
  final List<dynamic> cartItems;
  final Map<String, dynamic> orderDetails;
  final TextEditingController bankAccountController;
  final TextEditingController ifscController;
  final TextEditingController branchController;
  final TextEditingController holderNameController;
  final Function(bool) onOrderReturned;

  ReturnOrderDialog({
    required this.orderId,
    required this.productId,
    required this.userId,
    required this.cartItems,
    required this.orderDetails,
    required this.bankAccountController,
    required this.ifscController,
    required this.branchController,
    required this.holderNameController,
    required this.onOrderReturned,
  });

  @override
  _ReturnOrderDialogState createState() => _ReturnOrderDialogState();
}

class _ReturnOrderDialogState extends State<ReturnOrderDialog> {
  String selectedReason = "Damaged product"; // Default reason
  String otherReason = "";
  bool showOtherField = false;
  TextEditingController confirmAccountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Return Order"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reason for return
            Text("Select Reason:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: [
                "Damaged product",
                "Incorrect item received",
                "Item no longer needed",
                "Other"
              ].map((reason) {
                return RadioListTile(
                  title: Text(reason),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value!;
                      showOtherField = selectedReason == "Other";
                    });
                  },
                );
              }).toList(),
            ),

            // Other Reason Input Field
            if (showOtherField)
              TextField(
                decoration: InputDecoration(labelText: "Specify your reason"),
                onChanged: (value) => otherReason = value,
              ),

            SizedBox(height: 10),

            // Bank Details for Refund
            Text("Bank Details for Refund",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: widget.bankAccountController,
              decoration: InputDecoration(labelText: "Account Number"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: confirmAccountController,
              decoration: InputDecoration(labelText: "Confirm Account Number"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: widget.ifscController,
              decoration: InputDecoration(labelText: "IFSC Code"),
            ),
            TextField(
              controller: widget.branchController,
              decoration: InputDecoration(labelText: "Branch"),
            ),
            TextField(
              controller: widget.holderNameController,
              decoration: InputDecoration(labelText: "Account Holder Name"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
        ElevatedButton(
          onPressed: () => _processReturnRequest(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text("Confirm Return", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _processReturnRequest(BuildContext context) async {
    // Validate bank details
    if (widget.bankAccountController.text.trim().isEmpty ||
        widget.ifscController.text.trim().isEmpty ||
        widget.branchController.text.trim().isEmpty ||
        widget.holderNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all bank details for a refund"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate account number confirmation
    if (widget.bankAccountController.text != confirmAccountController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account numbers do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Final reason
    String finalReason = selectedReason == "Other"
        ? (otherReason.isNotEmpty ? otherReason : "No reason specified")
        : selectedReason;

    try {
      // Call API to return order
      bool success = await OrderDetailService.cancelOrder(
        widget.orderId,
        widget.userId,
        widget.productId,
        finalReason,
        {
          "accountNumber": widget.bankAccountController.text.trim(),
          "ifscCode": widget.ifscController.text.trim(),
          "branch": widget.branchController.text.trim(),
          "accountHolderName": widget.holderNameController.text.trim()
        },
        widget.orderDetails,
      );

      if (success) {
        widget.onOrderReturned(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order returned successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to return order. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error returning order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    confirmAccountController.dispose();
    super.dispose();
  }
}
