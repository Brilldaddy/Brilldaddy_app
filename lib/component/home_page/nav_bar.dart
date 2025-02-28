// ignore_for_file: unused_element

import 'package:brilldaddy/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/Search_Screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/wishlist.dart';

class NavigationBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey; // ✅ Accept scaffold key

  const NavigationBar({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavigationBarState extends State<NavigationBar> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset('assets/logo.png', height: 50),
      actions: [
        _buildIcon(Icons.search, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchScreen()));
        }),
        _buildIcon(Icons.favorite, () {
          _Wishlist(context);
        }, color: Colors.red),
        _buildIcon(Icons.shopping_cart, () {
          _handleCartAction(context);
        }),
        _buildIcon(Icons.more_vert, () {
          widget.scaffoldKey.currentState?.openEndDrawer(); // ✅ Open Drawer
        }),
      ],
    );
  }

  IconButton _buildIcon(IconData icon, VoidCallback onPressed, {Color? color}) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }

  void _navigateToLoginIfNotLoggedIn(BuildContext context) {
    if (!isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  void _handleCartAction(BuildContext context) {
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(),
        ),
      );
    } else {
      _navigateToLoginIfNotLoggedIn(context);
    }
  }

  void _Wishlist(BuildContext context) {
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WishlistPage(),
        ),
      );
    } else {
      _navigateToLoginIfNotLoggedIn(context);
    }
  }
}
