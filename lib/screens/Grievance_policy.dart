import 'package:flutter/material.dart';

class GrievanceRedressalPolicyPage extends StatelessWidget {
  const GrievanceRedressalPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grievance Redressal Policy",
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
            Text(
              "GRIEVANCE REDRESSAL POLICY",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("INTRODUCTION"),
            Text(
              "1.1. This grievance redressal policy (the “Policy”) sets out BRILLDADDY ECOMMERCE PVT. LTD’s (the “Company” or “We” or “Us”) policy towards redressing grievances raised by customers (“Consumer” or “You”) purchasing Products from the Company’s website, www.brilldaddy.com or mobile application (“Systems”) from time to time.\n\n"
              "1.2. Grievance: A grievance means any issue related to a Product/service availed by the Consumer from Our Systems, for which the Consumer is seeking resolution.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("PURPOSE OF THE POLICY"),
            Text(
              "2.1. The Policy aims to address any Consumer complaints or issues through a well-defined and proper mechanism to ensure maximum consumer satisfaction.\n"
              "2.2. The Policy functions on attempting to ensure that the Consumers would be treated fairly at all times, and the Company would undertake its best efforts to resolve grievances promptly, efficiently and courteously.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("CONTACT DETAILS"),
            Text(
              "In case of any query or complaint the Consumer can approach Us and reach out to Us through the below mentioned details and We will be glad to assist You:\n"
              "i. Legal Entity Name: BRILLDADDY ECOMMERCE PVT. LTD\n"
              "ii. Registered Office: C1, HQ PLUS,4th floor, Above Dominos, Commercial Complex, Near Nexus Mall, Koramangala, Hosur Main Road, Taverekare, Bangalore, Karnataka, INDIA-560029\n"
              "iii. Contact us at www.brilldaddy.com\n"
              "iv. Customer Care Support number: +91 99951 24365\n"
              "v. Email: contact@brilldaddy.com",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("GRIEVANCE REDRESSAL MECHANISM"),
            Text(
              "(i) We believe customer satisfaction is our top most priority and hence we focus on providing the best experience to all our Consumers. We encourage any feedback to help us improve further. Consumers can visit Us at https://www.brilldaddy.com/support/ for solutions to frequently asked questions, and we are here to assist You.\n\n"
              "4.1. We will address Your grievances with respect to any Products or services provided over the Systems in a time-bound manner. We have a designated grievance officer (“Grievance Officer”) for resolving Your grievances in a timely manner. The Grievance Officer shall be responsible for Consumer grievance redressal in accordance with this Policy.\n\n"
              "Please contact Our Grievance Officer through the below mentioned details:\n"
              "Name: Blessy\n"
              "Email: info@brilldaddy.com\n\n"
              "4.2. Once a Consumer files a complaint via email or telephonic communication, the Consumer will receive an acknowledgement within 48 (forty-eight) hours, along with a unique ID for tracking the status of the complaint.\n"
              "(ii) The Grievance Officer will undertake best efforts to redress the grievances of the Consumer as expeditiously as possible and in accordance with the timeline as prescribed under the applicable laws.\n"
              "4.3. If the Consumer is not satisfied with the resolution provided by the Grievance Officer, they may escalate the complaint to higher authorities within the Company. Escalation details will be provided upon request.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("MODES OF FILING COMPLAINTS"),
            Text(
              "Email: cmd@brilldaddy.com\n"
              "Customer Care Number: +91 99951 24365\n"
              "Postal Address: C1, HQ PLUS,4th floor, Above Dominos, Commercial Complex, Near Nexus Mall, Koramangala, Hosur Main Road, Taverekare, Bangalore, Karnataka, INDIA-560029",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("CONSUMER RIGHTS & RESPONSIBILITIES"),
            Text(
              "To facilitate a smooth grievance resolution process, Consumers are requested to provide:\n"
              "• Order ID / Invoice Number for tracking purposes.\n"
              "• A brief description of the grievance along with supporting documents (if applicable).\n"
              "• A valid contact number or email for communication.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("GRIEVANCE CLOSURE"),
            Text(
              "A grievance will be considered as resolved and closed under the following circumstances:\n"
              "7.1. The complainant has communicated his/her acceptance of the response from the Grievance officer or another person associated with the Company; or\n"
              "7.2. The complainant has not responded within thirty (30) days of the receipt of a written response and has not raised any further grievance on the same matter.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildSectionTitle("PERIODIC REVIEW & UPDATES"),
            Text(
              "This Policy will be reviewed periodically and updated as required. Consumers are encouraged to check the latest version on Our website.",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
