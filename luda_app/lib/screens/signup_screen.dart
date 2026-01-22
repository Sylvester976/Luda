// signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _gender = 'male';
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://localhost:8000/api/register');
      final response = await http.post(
        url,
        body: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'gender': _gender,
          'dob': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('role_id', data['user']['role_id']);
        Navigator.pushReplacementNamed(context, '/client_home');
      } else {
        final data = json.decode(response.body);
        _showError(data['message'] ?? 'Registration failed');
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

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black87,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    ).then((picked) {
      if (picked != null) {
        setState(() => _selectedDate = picked);
      }
    });
  }

  void _showGenderPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Gender'),
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGenderOption('Male', 'male'),
            _buildGenderOption('Female', 'female'),
            _buildGenderOption('Other', 'other'),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () {
        setState(() => _gender = value);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected ? Colors.black.withOpacity(0.05) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.black87 : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
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
              Color(0xFFB794F6),
              Color(0xFFF5E6D3),
              Color(0xFFFFF4E6),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.content_cut,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 16),
                        // App name
                        Text(
                          'Luda',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create your account',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 30),
                        // Form fields
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Full name',
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 12),
                        _buildPasswordField(),
                        SizedBox(height: 12),
                        _buildGenderSelector(),
                        SizedBox(height: 12),
                        _buildDOBSelector(),
                        SizedBox(height: 24),
                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1C1C1E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Login link
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
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
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
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
        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20, right: 12),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
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
        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20, right: 12),
            child: Icon(Icons.lock_outline, color: Colors.black54, size: 20),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 52),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return InkWell(
      onTap: _showGenderPicker,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline, color: Colors.black54, size: 20),
            SizedBox(width: 12),
            Text(
              _gender[0].toUpperCase() + _gender.substring(1),
              style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.black54, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDOBSelector() {
    final bool hasSelectedDate = _selectedDate != DateTime(2000, 1, 1);

    return InkWell(
      onTap: _showDatePicker,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 20),
            SizedBox(width: 12),
            Text(
              hasSelectedDate
                  ? '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
                  : 'Date of birth',
              style: TextStyle(
                fontSize: 16,
                color: hasSelectedDate ? Colors.black87 : Colors.black38,
                fontWeight: hasSelectedDate ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.black54, size: 22),
          ],
        ),
      ),
    );
  }
}