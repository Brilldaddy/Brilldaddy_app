import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  final String aboutText = 
      "Welcome to www.brilldaddy.com\n\n"
      "At BrillDaddy, we are passionate about providing an exceptional online shopping experience. Our mission is to make it easy and enjoyable for our customers to discover and purchase the products they love.\n\n"
      "Our Story\n"
      "We are a team of entrepreneurs, innovators, and creatives united by a common goal: to revolutionize online shopping. With years of experience in e-commerce and a deep understanding of our customers’ needs, we have built a platform designed to make shopping effortless, efficient, and fun.\n\n"
      "Our Values\n"
      "• Customer Obsession – We place our customers at the heart of everything we do, listening to their feedback and striving to exceed their expectations.\n"
      "• Quality and Authenticity – We are committed to offering high-quality, genuine products. We work closely with our suppliers to ensure every product meets our rigorous standards.\n"
      "• Innovation and Creativity – We continuously seek new and better ways to serve our customers, encouraging innovation and creativity while taking calculated risks.\n\n"
      "What We Offer\n"
      "• A Wide Selection – From Fashion and Jewellery to Electronics, Home Appliances, Sports Goods, and more, we offer a diverse range of products.\n"
      "• Competitive Prices – We provide great value without compromising on quality.\n"
      "• Fast, Reliable Shipping – We know timely delivery matters, and we work hard to ensure our customers receive their orders quickly and efficiently.\n\n"
      "Join Our Community\n"
      "We are building a community of like-minded individuals who share our passion for e-commerce and customer satisfaction. Follow us on social media, subscribe to our newsletter, or simply explore our website for the latest products, promotions, and news.\n\n"
      "Get in Touch\n"
      "We’d love to hear from you! Whether you have a question, comment, or concern, please feel free to contact us by phone, email, or through our website’s contact form.\n\n"
      "Thank you for choosing www.brilldaddy.com. We look forward to serving you!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: const Text("About BrillDaddy"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to www.brilldaddy.com",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              aboutText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
         
          ],
        ),
      ),
    );
  }
}
