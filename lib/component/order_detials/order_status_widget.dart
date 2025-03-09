import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? order;

  const OrderStatusWidget({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (order == null || order!['status'] == null) {
      return SizedBox(); // Return an empty widget if order data is missing
    }

    String status = order!['status'].toString().toLowerCase().trim();

    List<Map<String, dynamic>> statuses = [
      {
        "label": "Processing",
        "icon": FontAwesomeIcons.clock,
        "color": Colors.blue
      },
      {
        "label": "Shipped",
        "icon": FontAwesomeIcons.truck,
        "color": Colors.orange
      },
      {
        "label": "Out for Delivery",
        "icon": FontAwesomeIcons.truckMoving,
        "color": Colors.purple
      },
      {
        "label": "Delivered",
        "icon": FontAwesomeIcons.checkCircle,
        "color": Colors.green
      },
    ];

    // Handle Cancelled or Returned orders separately
    if (status == "cancelled" || status == "returned") {
      return Center(
        child: Column(
          children: [
            Icon(FontAwesomeIcons.timesCircle, color: Colors.red, size: 50),
            SizedBox(height: 5),
            Text(
              "Order ${status[0].toUpperCase() + status.substring(1)}",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      );
    }

    // Find index of current order status
    int currentIndex = statuses
        .indexWhere((element) => element['label'].toLowerCase() == status);
    if (currentIndex == -1) {
      currentIndex = 0; // Default to Processing
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: statuses.map((stage) {
            int stageIndex = statuses.indexOf(stage);
            bool isCompleted = stageIndex <= currentIndex;

            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isCompleted ? stage['color'] : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(stage['icon'], color: Colors.white, size: 16),
                    ),
                    if (stageIndex < statuses.length - 1)
                      Positioned(
                        right: -35,
                        child: Container(
                          height: 4,
                          width: 30,
                          color: stageIndex < currentIndex
                              ? stage['color']
                              : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  stage['label'],
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? stage['color'] : Colors.grey),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: (currentIndex + 1) / statuses.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            statuses[currentIndex]['color'],
          ),
        ),
      ],
    );
  }
}
