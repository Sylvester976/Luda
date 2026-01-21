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
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 300,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 50,
                color: CupertinoColors.systemGrey6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: Text('Done'),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => _selectedDate = newDate);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      ).then((picked) {
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      });
    }
  }

  void _showGenderPicker() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 250,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 50,
                color: CupertinoColors.systemGrey6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: Text('Done'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _gender = ['male', 'female', 'other'][index];
                    });
                  },
                  children: [
                    Center(child: Text('Male')),
                    Center(child: Text('Female')),
                    Center(child: Text('Other')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Gender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Male'),
                value: 'male',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() => _gender = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text('Female'),
                value: 'female',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() => _gender = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text('Other'),
                value: 'other',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() => _gender = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _buildIOSLayout();
    } else {
      return _buildMaterialLayout();
    }
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _buildLogo(true),
                    SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildNameField(true),
                    SizedBox(height: 16),
                    _buildEmailField(true),
                    SizedBox(height: 16),
                    _buildPasswordField(true),
                    SizedBox(height: 16),
                    _buildGenderSelector(true),
                    SizedBox(height: 16),
                    _buildDOBSelector(true),
                    SizedBox(height: 32),
                    _buildSignupButton(true),
                    Spacer(),
                    _buildLoginLink(true),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildLogo(false),
              SizedBox(height: 24),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign up to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40),
              _buildNameField(false),
              SizedBox(height: 16),
              _buildEmailField(false),
              SizedBox(height: 16),
              _buildPasswordField(false),
              SizedBox(height: 16),
              _buildGenderSelector(false),
              SizedBox(height: 16),
              _buildDOBSelector(false),
              SizedBox(height: 32),
              _buildSignupButton(false),
              SizedBox(height: 24),
              _buildLoginLink(false),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isIOS) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isIOS ? CupertinoColors.activeBlue : Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isIOS ? CupertinoIcons.person_add : Icons.person_add,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildNameField(bool isIOS) {
    if (isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CupertinoTextField(
          controller: _nameController,
          placeholder: 'Full Name',
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          prefix: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(CupertinoIcons.person, color: CupertinoColors.systemGrey),
          ),
        ),
      );
    } else {
      return TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Full Name',
          prefixIcon: Icon(Icons.person_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      );
    }
  }

  Widget _buildEmailField(bool isIOS) {
    if (isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CupertinoTextField(
          controller: _emailController,
          placeholder: 'Email',
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          prefix: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
          ),
        ),
      );
    } else {
      return TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      );
    }
  }

  Widget _buildPasswordField(bool isIOS) {
    if (isIOS) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CupertinoTextField(
          controller: _passwordController,
          placeholder: 'Password',
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          obscureText: _obscurePassword,
          prefix: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(CupertinoIcons.lock, color: CupertinoColors.systemGrey),
          ),
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              color: CupertinoColors.systemGrey,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      );
    } else {
      return TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      );
    }
  }

  Widget _buildGenderSelector(bool isIOS) {
    if (isIOS) {
      return GestureDetector(
        onTap: _showGenderPicker,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.person_2, color: CupertinoColors.systemGrey),
              SizedBox(width: 16),
              Text(
                _gender[0].toUpperCase() + _gender.substring(1),
                style: TextStyle(fontSize: 16, color: CupertinoColors.label),
              ),
              Spacer(),
              Icon(CupertinoIcons.chevron_down, color: CupertinoColors.systemGrey, size: 20),
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: _showGenderPicker,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.people_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_gender[0].toUpperCase() + _gender.substring(1)),
              Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDOBSelector(bool isIOS) {
    if (isIOS) {
      return GestureDetector(
        onTap: _showDatePicker,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.calendar, color: CupertinoColors.systemGrey),
              SizedBox(width: 16),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(fontSize: 16, color: CupertinoColors.label),
              ),
              Spacer(),
              Icon(CupertinoIcons.chevron_down, color: CupertinoColors.systemGrey, size: 20),
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: _showDatePicker,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSignupButton(bool isIOS) {
    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(12),
          onPressed: _isLoading ? null : _register,
          child: _isLoading
              ? CupertinoActivityIndicator(color: CupertinoColors.white)
              : Text('Sign Up', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text('Sign Up', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      );
    }
  }

  Widget _buildLoginLink(bool isIOS) {
    if (isIOS) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 15),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }
  }
}