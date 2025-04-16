import 'package:flutter/material.dart';
import 'dart:convert';
import '../component/home_page/ProductScreen.dart';
import '../component/home_page/catagory_product_list.dart';
import '../component/voucher_page/winner_page.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../component/home_page/advertisements.dart';
import '../component/home_page/nav_bar.dart' as custom;
import '../component/home_page/drawer.dart';
import '../component/home_page/category_scroller_screen.dart';
import '../component/home_page/voucher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> productFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    productFuture = apiService.fetchProducts();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> saveUserData(String userId, String authToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId.trim());
    await prefs.setString('authToken', authToken.trim());
    await prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: custom.NavigationBar(scaffoldKey: _scaffoldKey),
      endDrawer: const DrawerMenu(),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 195, 228, 239),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdvertisementCarousel(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WinnersMarquee(),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Exclusive Vouchers",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 300, child: VoucherScreen()),
              const CategoryScroller(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Products",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 300, child: ProductScreen()),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Products by Category",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Wrap CategoryProductList in a constrained container
             
                 const CategoryProductList(),
              
            ],
          ),
        ),
      ),
    );
  }
}