// login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://localhost:8000/api/login');
      final response = await http.post(
        url,
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('role_id', data['user']['role_id']);

        // Navigate based on role
        switch (data['user']['role_id']) {
          case 4:
            Navigator.pushReplacementNamed(context, '/client_home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/superadmin_home');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/barber_owner_home');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/barber_home');
            break;
        }
      } else {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showError('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB794F6), // Purple
              Color(0xFFF5E6D3), // Cream
              Color(0xFFFFF4E6), // Light cream
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.content_cut,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // App name
                Text(
                  'Luda',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 60),
                // Email field
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                // Password field
                _buildPasswordField(),
                SizedBox(height: 32),
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1C1C1E), // Dark gray/black
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Sign in now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Sign up link
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        style: TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 24, right: 16),
            child: Icon(icon, color: Colors.black54, size: 22),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 62),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 24, right: 16),
            child: Icon(Icons.lock_outline, color: Colors.black54, size: 22),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 62),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
                size: 22,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}