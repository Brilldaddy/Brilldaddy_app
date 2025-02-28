import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
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
                "1. Introduction",
                "Brilldaddy ECommerce Pvt. Ltd is committed to protecting your personal information. "
                    "This policy explains how we collect, use, and safeguard your data in compliance with "
                    "the Information Technology Act, 2000."),
            _buildExpandableSection("2. Information We Collect", [
              "• Personal Information: Name, Email, Phone, Address, Payment Info, Date of Birth, Gender.",
              "• Sensitive Data (SPDI): Financial details, passwords, legal information.",
              "• Non-Personal Information: IP Address, Browser type, Device details, Cookies & Usage Data."
            ]),
            _buildExpandableSection("3. Purpose of Data Collection", [
              "• To process transactions & provide services.",
              "• To improve user experience and personalize services.",
              "• To comply with legal obligations and prevent fraud.",
            ]),
            _buildExpandableSection("4. Data Sharing & Disclosure", [
              "• We do not sell or trade personal data.",
              "• We may share data with trusted third-party service providers (payments, logistics, support).",
              "• Data may be shared if legally required or in business transfers (e.g., mergers, acquisitions).",
            ]),
            _buildExpandableSection("5. Security of Personal Information", [
              "• SSL encryption for secure data transmission.",
              "• Restricted access to sensitive data.",
              "• Regular security audits and assessments.",
            ]),
            _buildExpandableSection("6. Retention of Data", [
              "• Data is retained only for necessary business and legal purposes.",
              "• Upon request, data will be deleted or anonymized as per legal guidelines.",
            ]),
            _buildExpandableSection("7. Your Rights", [
              "• Access, update, or correct personal data.",
              "• Withdraw consent for data processing.",
              "• Request deletion of data.",
            ]),
            _buildContactSection("Email: brilldaddyindia@gmail.com"),
            const Divider(thickness: 2, color: Colors.blueAccent),
            const SizedBox(height: 20),
            _buildTitle("Data Protection Policy"),
            _buildExpandableSection("1. Scope", [
              "• Applies to all employees, vendors, and third parties handling Brilldaddy user data."
            ]),
            _buildExpandableSection("2. Data Collection", [
              "• Data collection must be lawful and transparent.",
              "• Consent is required for collecting sensitive data as per IT Act, 2000."
            ]),
            _buildExpandableSection("3. Security Measures", [
              "• Data encryption & secure access controls.",
              "• Employee training on data security.",
              "• Regular security audits & risk assessments.",
            ]),
            _buildExpandableSection("4. Data Breach Management", [
              "• Affected users and authorities will be notified promptly.",
              "• Investigations and corrective actions will be taken immediately.",
            ]),
            _buildExpandableSection("5. Third-Party Vendors", [
              "• All vendors handling data must comply with data protection laws.",
              "• Vendors must sign data protection agreements with Brilldaddy.",
            ]),
            _buildContactSection(
                "For any concerns, contact our Data Protection Officer at brilldaddyindia@gmail.com"),
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
