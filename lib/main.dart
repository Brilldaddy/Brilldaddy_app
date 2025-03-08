import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_page.dart';
import 'component/home_page/popup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brilldaddy',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isPopupOpen = false;
  List<String> _popupImages = [];

  @override
  void initState() {
    super.initState();
    _checkPopupStatus();
    _fetchPopupImages();
  }

  Future<void> _checkPopupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPopupOpen = !(prefs.getBool('popupShown') ?? false);
    });
  }

  void _closePopup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('popupShown', true);
    setState(() {
      _isPopupOpen = false;
    });
  }

  Future<void> _fetchPopupImages() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.brilldaddy.com/api/user/popup'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imagesArray = data is List ? data : [];
        setState(() {
          _popupImages = imagesArray
              .map<String>((item) => item['imageUrl'] as String)
              .toList();
          _isPopupOpen = _popupImages.isNotEmpty;
        });
      } else {
        setState(() {
          _popupImages = [];
        });
      }
    } catch (error) {
      print("Error fetching popup images: $error");
      setState(() {
        _popupImages = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomePage(),
          if (_isPopupOpen && _popupImages.isNotEmpty)
            Popup(
              imageUrl: _popupImages[0],
              onClose: _closePopup,
            ),
        ],
      ),
    );
  }
}
