// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/ContactUsPage.dart';
import '../../screens/Grievance_policy.dart';
import '../../screens/PrivacyPolicyPage.dart';
import '../../screens/RefundPolicyPage.dart';
import '../../screens/ShippingAndDelivery.dart';
import '../../screens/WalletScreen.dart';
import '../../screens/about.dart';
import '../../screens/account.dart';
import '../../screens/login_screen.dart';
import '../../screens/shop_category_page.dart';
import '../../screens/terms_and_condition.dart';
import '/../services/api_service.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool isLoggedIn = false;
  String username = "";
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadCategories();
  }

  Future<void> _setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      username = prefs.getString('username') ?? "User";
    });
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await ApiService().fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
      username = "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.person_2_rounded, 'Account', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          }),
          _buildDrawerItem(Icons.account_balance_wallet_rounded, 'Wallet', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletScreen(),
              ),
            );
          }),
          ExpansionTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            children: categories.map((category) {
              return ListTile(
                title: Text(category['name']),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShopCategoryPage(category: category['name']),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          _buildDrawerItem(Icons.contact_support, 'Contact Support', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactUsPage(),
              ),
            );
          }),
          _buildDrawerItem(Icons.info, 'About Us', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AboutUsPage(),
              ),
            );
          }),
          _buildDrawerItem(
              Icons.private_connectivity_outlined, 'Privacy Policy', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrivacyPolicyPage(),
              ),
            );
          }),
          _buildDrawerItem(Icons.attach_money, 'Return And Cancellation Policy', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RefundPolicyPage(),
              ),
            );
          }),
          _buildDrawerItem(Icons.description, 'Terms and Conditions', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TermsAndConditionPage(),
              ),
            );
          }),
          _buildDrawerItem(Icons.local_shipping, 'Shipping and Delivery', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ShippingAndDeliveryPage(), // Replace with your actual page
              ),
            );
          }),
          _buildDrawerItem(Icons.policy, 'Grievance Redressal Policy', () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GrievanceRedressalPolicyPage(), // Replace with your actual page
    ),
  );
}),
          _buildDrawerItem(
            isLoggedIn ? Icons.logout : Icons.login,
            isLoggedIn ? 'Logout' : 'Login',
            () async {
              if (isLoggedIn) {
                await _handleLogout();
                Navigator.pop(context);
              } else {
                final result = await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );

                if (result == true) {
                  _checkLoginStatus();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(isLoggedIn ? Icons.person : Icons.login,
                size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  isLoggedIn ? 'Hello, $username!' : 'Welcome!',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Navigate to edit profile page or show dialog
                  print("Edit profile tapped");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
