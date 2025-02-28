import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'register_screen.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool isOtpSent = false;
  bool loadingOtp = false;
  bool loadingLogin = false;
  int timer = 120;
  Timer? _resendTimer;

  /// Function to request OTP from server
  Future<void> _handleOtpRequest() async {
    if (_identifierController.text.isEmpty) {
      _showError('Please enter your phone number or email.');
      return;
    }

    setState(() {
      loadingOtp = true;
    });

    try {
      var response = await Dio().post(
        'https://api.brilldaddy.com/api/user/sendOtp',
        data: {'identifier': _identifierController.text},
      );

      if (response.statusCode == 200 &&
          response.data['message'] == 'OTP sent successfully') {
        setState(() {
          isOtpSent = true;
          _startTimer(); // Start OTP timer
        });
      } else {
        _showError(response.data['message'] ??
            'Failed to send OTP. Please try again.');
      }
    } on DioError catch (dioError) {
      _showError('Network error: ${dioError.message}');
    } catch (error) {
      _showError('An unexpected error occurred.');
    } finally {
      setState(() {
        loadingOtp = false;
      });
    }
  }

  /// Function to verify OTP and login
  Future<void> _handleOtpVerification() async {
    if (_otpController.text.isEmpty) {
      _showError('Please enter the OTP.');
      return;
    }

    setState(() {
      loadingLogin = true;
    });

    try {
      var response = await Dio().post(
        'https://api.brilldaddy.com/api/user/verify-otp',
        data: {
          'identifier': _identifierController.text,
          'otp': _otpController.text,
        },
      );

      print('OTP Verification Response: ${response.data}');

      if (response.statusCode == 200 &&
          response.data['message'] == 'OTP verified, login successful') {
        final token = response.data['token']; // Get token from response

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);

          // Fetch user details
          await _fetchUserDetails(token);
        } else {
          _showError('Token missing. Please try again.');
        }
      } else {
        _showError(
            response.data['message'] ?? 'Invalid OTP. Please try again.');
      }
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        print('Dio Response Error: ${dioError.response?.data}');
        _showError(
            'Server error: ${dioError.response?.data['message'] ?? 'Unknown error'}');
      } else if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        _showError('Connection timed out. Please try again.');
      } else if (dioError.type == DioExceptionType.unknown) {
        _showError('No internet connection. Please check your network.');
      } else {
        _showError('Unexpected error: ${dioError.message}');
      }
    } catch (error) {
      print('Unexpected error: $error');
      _showError('Something went wrong. Please try again.');
    } finally {
      setState(() {
        loadingLogin = false;
      });
    }
  }

  /// Function to fetch user details after login
  Future<void> _fetchUserDetails(String token) async {
    try {
      var response = await Dio().get(
        'https://api.brilldaddy.com/api/user/getUserDetails',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Attach token
          },
        ),
      );

      if (response.statusCode == 200) {
        final userData = response.data;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userData['_id'].toString());
        await prefs.setString('username', userData['username']);
        await prefs.setBool('isLoggedIn', true);

        print("%%%%%%%%%%%%%%%%%%");
       print('Login Successful!');
      print('User ID: ${userData['_id']}');
      print('Username: ${userData['username']}');
        print("%%%%%%%%%%%%%%%%%%");


        // Navigate to Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showError('Failed to fetch user details.');
      }
    } catch (error) {
      _showError('Error fetching user details.');
    }
  }

  /// Timer function for OTP resend countdown
  void _startTimer() {
    setState(() {
      timer = 120;
    });

    _resendTimer?.cancel(); // Cancel existing timer if any
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timerInstance) {
      if (timer == 0) {
        timerInstance.cancel();
      } else {
        setState(() {
          timer--;
        });
      }
    });
  }

  /// Function to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  /// UI of the Login Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 228, 239),
      appBar: AppBar(
        title: Text('Login',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 80), // Logo
                    SizedBox(height: 20),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login with your phone number or email to continue.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _identifierController,
                decoration: InputDecoration(
                  labelText: 'Phone or Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.person, color: Colors.indigo),
                ),
              ),
              if (isOtpSent)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: loadingOtp ? null : _handleOtpRequest,
                child: loadingOtp
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Get OTP',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              if (isOtpSent)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: loadingLogin ? null : _handleOtpVerification,
                    child: loadingLogin
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Verify OTP',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    },
                    child: Text('Sign Up',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
