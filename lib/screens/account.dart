import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/account/AddressListPage.dart';
import '../component/account/BidProductsPage.dart';
import '../component/account/WinnerAlbumPage.dart';
import '../component/account/personal_info.dart';
import '../services/wishlist.dart' as wishlistService;
import 'order_list_screen.dart';
import 'wishlist.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userId = '';
  String token = '';
  String profileImage =
      "https://static-00.iconduck.com/assets.00/user-icon-1024x1024-dtzturco.png";
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      token = prefs.getString('authToken') ?? '';
    });
    if (userId.isNotEmpty && token.isNotEmpty) {
      fetchUserInfo();
    } else {
      print('UserId or token not available.');
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${wishlistService.SERVER_URL}/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
          profileImage = userInfo['profileImage'] ?? profileImage;
        });
      } else {
        print('Failed to fetch user info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Future<void> handleImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImage = image.path;
      });
    }
  }

  Widget buildListItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18),
                        onPressed: handleImageUpload,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userInfo['username'] ?? 'User',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                userInfo['email'] ?? 'user@example.com',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              buildListItem('Personal Information', Icons.person, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInformationPage(),
                  ),
                );
              }),
              buildListItem('Manage Address', Icons.home, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddressListPage()),
                );
              }),
              buildListItem('Win Album', Icons.emoji_events, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WinnerAlbumPage(),
                  ),
                );
              }),
              buildListItem('Attempt Products', Icons.shopping_bag, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BidProductsPage(),
                  ),
                );
              }),
              buildListItem('My Orders', Icons.shopping_cart, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdersList(),
                  ),
                );
              }),
              buildListItem('My Wishlist', Icons.favorite, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WishlistPage(),
                  ),
                );
              }),
              // buildListItem('Logout', Icons.logout, () {}),
            ],
          ),
        ),
      ),
    );
  }
}
