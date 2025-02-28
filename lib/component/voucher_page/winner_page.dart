import 'package:flutter/material.dart';

class WinnersSection extends StatelessWidget {
  final Future<List<dynamic>>? winners;

  WinnersSection({required this.winners});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: winners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("Error loading winners")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No winners found")),
          );
        }

        final winnersList = snapshot.data!;
        return SizedBox(
          height: 180, // Adjusted height for better visibility
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: winnersList.length,
            itemBuilder: (context, index) {
              final winner = winnersList[index];
              final voucher = winner['voucherId'] as Map<String, dynamic>?;
              final user = winner['userId'] as Map<String, dynamic>?;

              return Card(
                elevation: 5,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(8.0),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: user?['profileImage'] != null
                                ? ClipOval(
                                    child: Image.network(
                                      user!['profileImage'],
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.person, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              user?['username'] ?? "Unknown User",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        voucher?['voucher_name'] ?? "Voucher Name",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Product: ${voucher?['product_name'] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        "Winning Amount: ₹${winner['winningAmount'] ?? '0'}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
