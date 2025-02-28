import 'package:brilldaddy/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:dio/dio.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  String username = '';
  String email = '';
  String phone = '';
  String successMessage = '';
  String errorMessage = '';

  Future<Position> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      successMessage = '';
      errorMessage = '';
    });

    try {
      Position location = await _fetchLocation();
     var response = await Dio().post(
  'https://api.brilldaddy.com/api/user/register',
  data: {
    'username': username,
    'email': email,
    'phone': phone,
    'location': {
      'latitude': location.latitude,
      'longitude': location.longitude,
    }
  },
  options: Options(validateStatus: (status) => status! < 500), // Accept 409 as a valid response
);

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

     if (response.statusCode == 200 || response.statusCode == 201) {
  setState(() {
    successMessage = 'Registration successful!';
  });
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  });
} else if (response.statusCode == 409) {
  setState(() {
    errorMessage = 'User already exists. Please log in.';
  });
} else {
  setState(() {
    errorMessage = 'Registration failed: ${response.data['message'] ?? 'Unknown error'}';
  });
}

    } on DioException catch (dioError) {
      print('DioError: ${dioError.message}');
      setState(() {
        errorMessage = 'Network error: ${dioError.message}';
      });
    } catch (error) {
      print('Error: $error');
      setState(() {
        errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Register',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 80),
              SizedBox(height: 20),
              Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Sign up with your details to get started.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              _buildTextField(
                label: 'Username',
                icon: Icons.person,
                onChanged: (value) => username = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required.';
                  } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) {
                    return 'Username can only contain letters and spaces.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              _buildTextField(
                label: 'Email',
                icon: Icons.email,
                onChanged: (value) => email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required.';
                  } else if (!RegExp(
                          r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email.';
                  } else if (!value.toLowerCase().contains('@gmail')) {
                    return 'Only Gmail addresses are allowed.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              _buildTextField(
                label: 'Phone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                onChanged: (value) => phone = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required.';
                  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Phone number must be a 10-digit number.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSubmitting ? null : _handleSubmit,
                  child: isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
              if (successMessage.isNotEmpty)
                Text(
                  successMessage,
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
