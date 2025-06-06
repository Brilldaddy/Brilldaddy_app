import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
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
            _buildTitle("Privacy Policy of Brilldaddy ECommerce Pvt Ltd"),
            const SizedBox(height: 10),
            _buildSection(
                "I. Introduction",
                "This privacy policy (“Policy”) sets out the manner in which Brilldaddy ECommerce Pvt. Ltd., "
                "(“We”, “Our”, “Us”) collects, uses, maintains and shares information about you (“User” or “You”) "
                "through online interfaces (e.g. - mobile applications, website) owned and controlled by Us (collectively referred to herein as the “Systems”). "
                "Please read and understand the Policy carefully. Your use or access of Our Systems shall constitute Your agreement to this Policy. "
                "This Policy has been drafted in accordance with the DIGITAL PERSONAL DATA PROTECTION ACT, 2023 (DPDP ACT), THE INFORMATION TECHNOLOGY ACT, 2000, "
                "and the relevant applicable data protection rules to Our business."),
            _buildSection(
                "II. Applicability of the Policy",
                "(a) This Policy shall apply to all information We collect through the Systems and/or in the course of Your use of Our System.\n"
                "(b) This Policy does not apply to, nor do we take any responsibility for, any information that is collected by any third party either using Systems or through any links on the Systems or through any of the advertisements or through BOTS.\n"
                "(c) This Policy is an electronic record generated by a computer system and does not require any physical or digital signatures."),
            _buildExpandableSection("III. Information We Collect", [
              "• Personal information submitted during registration such as name, age, sex, birth date, etc.",
              "• Contact details including email address, phone numbers, shipping and billing addresses.",
              "• Information about Your computer system, device ID, IP address, browser details, cookies, and location.",
              "• Payment details and credit history information.",
              "• Information collected through cookies, analytical tools, and third-party sources."
            ]),
            _buildExpandableSection("IV. Manner of Collection of Information", [
              "• Information provided directly by You during registration or use of the Systems.",
              "• Information collected automatically through cookies, sessions, and tracking technologies.",
              "• Information accessed from third-party sources such as social media or marketing partners."
            ]),
            _buildExpandableSection("V. Use of Your Information", [
              "• To improve Our platform and prevent fraud.",
              "• To provide order history, account settings, and personalized services.",
              "• To analyze and improve marketing and promotional efforts.",
              "• To comply with legal obligations and prevent unauthorized activities."
            ]),
            _buildExpandableSection("VI. Disclosure of Your Information", [
              "• Shared with employees, agents, and third-party service providers under confidentiality agreements.",
              "• Shared with governmental or regulatory authorities as required by law.",
              "• Not sold or rented to third parties for marketing purposes without explicit consent."
            ]),
            _buildExpandableSection("VII. Retention and Storage", [
              "• Information is retained for the period necessary to fulfill the purposes outlined in this Policy.",
              "• Data is anonymized upon account cancellation, except for legal or regulatory purposes.",
              "• Data is stored and processed in India under applicable laws."
            ]),
            _buildExpandableSection("VIII. Data Security", [
              "• Security measures include firewalls, encryption, and secure access controls.",
              "• Users are responsible for maintaining the confidentiality of their authentication credentials.",
              "• While best efforts are made, complete security cannot be guaranteed."
            ]),
            _buildExpandableSection("IX. Accessing and Updating Your Information", [
              "• Users can update, modify, or delete their information through the Systems.",
              "• Users can opt out of targeted advertising and withdraw consent for data processing.",
              "• Users are responsible for maintaining the accuracy of their submitted information."
            ]),
            _buildSection(
                "X. Age Restrictions",
                "The Systems are intended for users aged 18 or older. If information belonging to individuals below 18 is submitted, it will be deleted."),
            _buildSection(
                "XI. Amendments to the Privacy Policy",
                "We may update this Policy to reflect changes in Our practices. Continued use of the Systems constitutes agreement to the revised Policy."),
            _buildSection(
                "XII. Complaints",
                "For grievances, contact CHIEF EXECUTIVE OFFICER at ceo@brilldaddy.com or write to BRILLDADDY ECOMMERCE PVT.LTD., "
                "C1, 4TH FLOOR, HQ PLUS, ABOVE DOMINOS, NEAR: NEXUS MALL, KORAMANGALA, BANGALORE, KARNATAKA, INDIA-560029, "
                "or phone at +91 99951 24365. Grievances will be addressed within 30 days."),
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
