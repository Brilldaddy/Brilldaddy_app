import 'package:flutter/material.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({Key? key}) : super(key: key);

  final String contactInfo =
      "Email: contact@brilldaddy.com\nPhone: +91 99951 24365";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Refund Policy",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Refund Policy of Brilldaddy Ecommerce Pvt Ltd"),
            const SizedBox(height: 10),
            _buildSection("1. RETURNS AND REPLACEMENTS",
                "At Brilldaddy, we are committed to ensuring Your satisfaction with every purchase. However, returns and replacements are subject to the following conditions:"),
            _buildExpandableSection("1.1. Eligible Return/Exchange Scenarios", [
              "Defective or Damaged Products:\n  o If You receive a Product with genuine defects, physical damage, or manufacturing flaws, please contact Our customer support within 7 calendar days of receiving the Product.\n  o You may be required to provide photographic or video evidence of the damage or defect.",
              "Wrong or Missing Items:\n  o If You receive an incorrect Product or if items are missing from Your order, report the issue within 7 calendar days of receipt.\n  o We will either arrange for the correct Product to be sent at no additional cost or issue a refund.",
              "Non-Delivery of Product:\n  o If Your order is not delivered within the estimated delivery timeline, please contact Us within 3 calendar days of the estimated delivery date to initiate an investigation."
            ]),
            _buildExpandableSection("1.2. Conditions for Return/Exchange", [
              "Unused and Original Condition:\n  o The Product must be returned in its original, unused, and unworn condition.\n  o All original tags, labels, and packaging must be intact.",
              "Mandatory Unboxing Video:\n  o A complete and uninterrupted unboxing video is mandatory for any return or exchange claims related to damage or discrepancies.\n  o The video must clearly show the package being opened, and the product being removed.",
              "Exclusions:\n  o Returns or exchanges are not accepted for:\n     Customized or personalized Products.\n     Digital Products or downloadable content.\n     Products where colour variations are due to screen settings.\n     Products that are used, damaged by the customer, or missing original packaging.",
              "Return Shipping:\n  o For returns due to incorrect order placed by the customer, the customer will be responsible for the return shipping cost.\n  o For returns due to our error, we will cover the return shipping cost."
            ]),
            _buildExpandableSection("1.3. Non-Returnable Products", [
              "Products purchased under special discounts, limited-time offers, or final clearance sales are non-returnable.",
              "Gift vouchers and e-coupons are non-returnable, non-exchangeable, and non-refundable.",
              "Certain hygiene-related items will not be returned."
            ]),
            _buildSection("2. CANCELLATION",
                "2.1. Order Cancellation by Customer\n• Orders can be cancelled before they are shipped.\n• Refunds for cancelled orders will be processed within 7-10 business days, after deducting any applicable bank transaction fees or payment gateway charges.\n• Orders that have been shipped or are in transit cannot be cancelled.\n• You will be notified regarding the cancellation status within 24 hours.\n• If a cancelled order is still delivered, please raise a return request within 24 hours of delivery."),
            _buildSection("3. REFUNDS", 
              "Refunds will be processed to the original payment method within 7-10 business days.\n Shipping fees, bank charges, and any non-refundable service charges may be deducted from the refund amount. \n Refunds will only be processed after the returned product has been received and inspected."
            ),
            _buildSection("4. DISPUTE RESOLUTION",
                "In case of any disputes related to returns, cancellations, or refunds, customers are encouraged to contact our customer support team to seek resolution. We will make every effort to resolve disputes amicably and fairly. If a dispute cannot be resolved through customer support, it may be subject to arbitration or litigation in accordance with Indian law."),
            _buildContactSection(contactInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade900,
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildExpandableSection(String title, List<String> contentList) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: contentList
          .map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: Text("• $item", style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
    );
  }

  Widget _buildContactSection(String contactInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.email, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              contactInfo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
