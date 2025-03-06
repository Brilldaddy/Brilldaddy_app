import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';

class InvoiceGenerator {
  Future<File> generateAndSaveInvoice(String orderId, Map<String, dynamic>? orderData) async {
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        build: (context) => pdfLib.Column(
          crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
          children: [
            pdfLib.Text("Invoice",
                style: pdfLib.TextStyle(fontSize: 24, fontWeight: pdfLib.FontWeight.bold)),
            pdfLib.SizedBox(height: 10),
            pdfLib.Text("Order ID: $orderId", style: pdfLib.TextStyle(fontSize: 16)),
            pdfLib.SizedBox(height: 5),
            
            // Add order details if available
            if (orderData != null) ...[
              pdfLib.Text("Order Date: ${orderData['createdAt'] ?? 'N/A'}", 
                  style: pdfLib.TextStyle(fontSize: 14)),
              pdfLib.SizedBox(height: 15),
              
              pdfLib.Text("Items:", 
                  style: pdfLib.TextStyle(fontSize: 16, fontWeight: pdfLib.FontWeight.bold)),
              pdfLib.SizedBox(height: 5),
              
              // Create table for items
              if (orderData.containsKey('cartItems') && orderData['cartItems'].isNotEmpty)
                pdfLib.Table(
                  border: pdfLib.TableBorder.all(),
                  children: [
                    // Table header
                    pdfLib.TableRow(
                      children: [
                        pdfLib.Padding(
                          padding: pdfLib.EdgeInsets.all(5),
                          child: pdfLib.Text("Item", 
                              style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold)),
                        ),
                        pdfLib.Padding(
                          padding: pdfLib.EdgeInsets.all(5),
                          child: pdfLib.Text("Quantity", 
                              style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold)),
                        ),
                        pdfLib.Padding(
                          padding: pdfLib.EdgeInsets.all(5),
                          child: pdfLib.Text("Price", 
                              style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold)),
                        ),
                        pdfLib.Padding(
                          padding: pdfLib.EdgeInsets.all(5),
                          child: pdfLib.Text("Total", 
                              style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold)),
                        ),
                      ],
                    ),
                    
                    // Table rows with item details
                    ...orderData['cartItems'].map<pdfLib.TableRow>((item) {
                      return pdfLib.TableRow(
                        children: [
                          pdfLib.Padding(
                            padding: pdfLib.EdgeInsets.all(5),
                            child: pdfLib.Text(item['productId']['name'] ?? 'Unknown'),
                          ),
                          pdfLib.Padding(
                            padding: pdfLib.EdgeInsets.all(5),
                            child: pdfLib.Text(item['quantity'].toString()),
                          ),
                          pdfLib.Padding(
                            padding: pdfLib.EdgeInsets.all(5),
                            child: pdfLib.Text("₹${item['price']}"),
                          ),
                          pdfLib.Padding(
                            padding: pdfLib.EdgeInsets.all(5),
                            child: pdfLib.Text("₹${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              
              pdfLib.SizedBox(height: 20),
              
              // Total amount
              pdfLib.Container(
                alignment: pdfLib.Alignment.centerRight,
                child: pdfLib.Text(
                  "Total Amount: ₹${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                  style: pdfLib.TextStyle(
                    fontSize: 16, 
                    fontWeight: pdfLib.FontWeight.bold
                  ),
                ),
              ),
            ],
            
            // Footer
            pdfLib.SizedBox(height: 30),
            pdfLib.Divider(),
            pdfLib.Text("Thank you for your purchase!"),
            pdfLib.SizedBox(height: 5),
            pdfLib.Text("For any questions, please contact customer support."),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Invoice_$orderId.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
}