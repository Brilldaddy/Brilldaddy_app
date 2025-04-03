import 'package:flutter/material.dart';

class ShippingAndDeliveryPage extends StatelessWidget {
  const ShippingAndDeliveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shipping and Delivery",
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
            _buildTitle(
                "Shipping and Delivery of Brilldaddy ECommerce Pvt Ltd"),
            const SizedBox(height: 10),
            _buildSection("1. Order Processing and Dispatch",
                "Once Your order is successfully placed and payment is confirmed, Our system processes the order."),
            _buildExpandableSection("1.1", [
              "Each Product undergoes a meticulous quality inspection to ensure it meets Our stringent standards.",
              "After passing the final quality checks, Products are securely packaged to prevent damage during transit.",
              "Shipments are handled by Our trusted delivery partners or our in-house logistics team, based on the serviceability of Your delivery location.",
              "We aim to deliver Your Product within 3-14 business days from the order and payment receipt, depending on the delivery address.",
              "Orders are processed Monday through Saturday, excluding public holidays.",
              "Orders placed before 11:00 AM IST are processed on the same business day.",
              "Orders placed after 11:00 AM IST are processed on the next business day.",
              "We will provide shipping confirmation through email and SMS."
            ]),
            _buildSection("2. Shipping Methods & Estimated Delivery Timelines",
                "Domestic Shipping (Within India):"),
            _buildExpandableSection("2.1", [
              "Shipping Type: Standard Shipping, Estimated Delivery Time: 3-14 business days, Charges: Free, Location: Applicable to all serviceable locations.",
              "Oversized/Bulk Orders: Variable, based on size and location. Additional handling and packaging charges may apply. We will contact You with the exact charges before dispatch.",
              "Additional notes:",
              "• Delivery timelines begin from the day following order processing.",
              "• Pin-code serviceability checks are mandatory before selecting Expedited or Express delivery.",
              "• Delivery times are estimates and not guarantees.",
              "• Oversized or bulk orders may be subject to additional handling and packaging charges."
            ]),
            _buildSection("3. Tracking & Notifications",
                "Upon dispatch, you will receive an email and SMS notification containing the tracking number and courier partner details."),
            _buildExpandableSection("3.1", [
              "Tracking updates will be available within 24 hours of shipment.",
              "You can track Your order via:",
              "• Our website (www.brilldaddy.com – “Track My Order” section).",
              "• The delivery partner’s official tracking page.",
              "If you face any issues with tracking, contact our support team.",
              "In case of delivery failure or delays beyond expected timelines, please contact Our support team at contact@brilldaddy.com or +91 9995124365."
            ]),
            _buildSection("4. Delivery",
                "Orders will be delivered by Our in-house team, third-party logistics companies, or postal services, depending on Your location."),
            _buildExpandableSection("4.1", [
              "Delivery will occur between 10:30 AM – 7:00 PM IST, Monday to Saturday.",
              "Orders placed on Sundays or public holidays will be processed on the next business day.",
              "All deliveries require a signature upon receipt or OTP verification (sent via SMS or email).",
              "If the order status shows 'Delivered' but You have not received it, please notify Us within 24 hours of the indicated delivery date.",
              "We are not liable for delays caused by incorrect addresses, recipient unavailability, or force majeure events (strikes, natural disasters, government restrictions, etc.).",
              "If a delivery attempt is unsuccessful due to an incorrect address or recipient unavailability, the courier will attempt delivery twice more. If all attempts fail, the package will be marked 'Return to Origin' (RTO).",
              "Customers may request re-shipment of RTO orders, subject to a re-shipping fee.",
              "Refunds are not provided for failed deliveries due to customer errors.",
              "We will attempt to contact the customer before processing an RTO."
            ]),
            _buildSection("5. High-Value Item Delivery",
                "For high-value items (as determined by Our company), additional verification steps may be implemented to ensure secure delivery."),
            _buildExpandableSection("5.1", [
              "These steps may include:",
              "• Requiring a government-issued photo ID upon delivery.",
              "• Mandatory OTP verification.",
              "• Signature confirmation.",
              "• Delivery only to the address specified on the order.",
              "• Video recording of the delivery process.",
              "We may contact You prior to delivery to arrange a suitable delivery time and to inform You of any specific delivery requirements.",
              "We reserve the right to refuse delivery if the verification requirements are not met."
            ]),
            _buildSection("6. Item Verification at Delivery",
                "Customers are strongly encouraged to inspect the package for any signs of damage or tampering before accepting delivery."),
            _buildExpandableSection("6.1", [
              "Upon receiving the package, customers should verify the contents against the order confirmation to ensure they have received the correct items.",
              "If any discrepancies, damages, or missing items are found, customers must immediately notify the delivery personnel and Our support team.",
              "Customers should take pictures or videos of any damages, or discrepancies.",
              "Do not sign the delivery acceptance, if the package appears to be tampered with.",
              "Any claims of damage or missing items reported after acceptance of delivery may not be honored."
            ]),
            _buildSection("7. Delivery Address Changes",
                "Address changes may be accommodated before the order is dispatched."),
            _buildExpandableSection("7.1", [
              "Once the order has been dispatched, address changes may not be possible.",
              "Customers must contact Our support team immediately if they need to change the delivery address.",
              "Address changes can cause delays in delivery."
            ]),
            _buildSection("8. Undeliverable Packages",
                "Packages may be deemed undeliverable due to reasons such as incorrect address, recipient unavailability, refusal to accept delivery, or access issues."),
            _buildExpandableSection("8.1", [
              "If a package is deemed undeliverable, it will be returned to Our warehouse.",
              "Customers will be notified, and options for re-shipment (with applicable fees) or refunds (minus shipping costs) will be provided."
            ]),
            _buildSection("9. Exceptions",
                "High-value orders may require additional verification before dispatch."),
            _buildExpandableSection("9.1", [
              "We will contact You for identity confirmation if necessary.",
              "We reserve the right to cancel or modify shipping terms at any time based on operational feasibility, business policies, or government regulations.",
              "For issues related to lost, delayed, or damaged shipments, customers must report the matter within 24 hours of the expected delivery date. Claims made after this period may not be honored.",
              "If a package is damaged during shipment, please take photos of the damaged package and items and send them to our support email.",
              "We are not responsible for delays caused by carrier delays.",
              "We reserve the right to change our delivery partners without notice."
            ]),
            _buildSection(
                "10. Contact Information",
                "For any shipping and delivery inquiries, please contact Our support team:\n"
                    "Email: contact@brilldaddy.com\n"
                    "Phone: +91 9995124365"),
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
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
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
}
