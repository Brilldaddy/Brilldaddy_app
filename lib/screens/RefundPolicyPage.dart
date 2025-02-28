import 'package:flutter/material.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({Key? key}) : super(key: key);

  final String refundPolicyText =
      "At Brilldaddy Ecommerce Pvt Ltd (hereinafter referred to as \"Brilldaddy\"), we are committed to providing our customers with the best shopping experience. We understand that there may be instances where a refund is necessary. Please review our refund policy outlined below.\n\n"
      "1. Refund Request Process\n"
      "   a. Submit a Refund Request through Email\n"
      "      - Send an email to our customer support team at [insert email address] with the subject line \"Refund Request - Order [Order ID]\".\n"
      "      - Please include the following information in your email:\n"
      "         • Full name\n"
      "         • Contact number\n"
      "         • Order ID\n"
      "         • Reason for the refund request\n"
      "         • Proof of purchase (e.g., order confirmation or invoice)\n"
      "   b. Submit a Refund Request via the Website\n"
      "      - Visit our website [insert website URL] and navigate to the \"Return and Refund\" tab.\n"
      "      - Fill out the refund request form with the necessary details, including your Order ID and reason for the refund.\n"
      "      Note: Both methods must be completed to process your refund.\n\n"
      "2. Refund Eligibility\n"
      "   Refunds may be granted for:\n"
      "      • Damaged or defective products upon delivery\n"
      "      • Incorrect items delivered\n"
      "      • Items that do not match the product description\n"
      "      • Change of mind returns (subject to specific product categories and conditions)\n"
      "   Conditions:\n"
      "      - The product must be returned in its original condition (with packaging, tags, and accessories).\n"
      "      - The request must be made within [X days] of receiving the order (e.g., 7-14 days).\n\n"
      "3. Processing Time\n"
      "   Once a refund request is received and approved, the refund will be processed within 10 working days. The amount will be credited directly to the customer's registered bank account. Please ensure correct bank details to avoid delays.\n\n"
      "4. Refund Amount\n"
      "   - The refund amount will equal the product price at the time of purchase, excluding shipping charges, unless the product was damaged, defective, or incorrect.\n"
      "   - For products purchased with a promotional offer or coupon, the refund amount will be adjusted accordingly.\n\n"
      "5. Non-Refundable Items\n"
      "   The following items are not eligible for refunds:\n"
      "      • Products purchased during clearance sales or marked as \"Final Sale\"\n"
      "      • Digital products, gift cards, and downloadable software\n"
      "      • Personalized or customized items\n\n"
      "6. Contact Us\n"
      "   If you have any questions regarding our refund policy, please contact our customer support team:\n"
      "      Email: brilldaddyindia@gmail.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Refund Policy",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Refund Policy of Brilldaddy Ecommerce Pvt Ltd",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              refundPolicyText,
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.justify,
            ),
         
          ],
        ),
      ),
    );
  }
}
