// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use Material for Android/Web, Cupertino theme for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoApp(
        title: 'Barber Booking',
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          brightness: Brightness.light,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/client_home': (context) => PlaceholderScreen(title: 'Client Home'),
          '/superadmin_home': (context) => PlaceholderScreen(title: 'Super Admin Home'),
          '/barber_owner_home': (context) => PlaceholderScreen(title: 'Barber Owner Home'),
          '/barber_home': (context) => PlaceholderScreen(title: 'Barber Home'),
        },
      );
    } else {
      return MaterialApp(
        title: 'Barber Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/client_home': (context) => PlaceholderScreen(title: 'Client Home'),
          '/superadmin_home': (context) => PlaceholderScreen(title: 'Super Admin Home'),
          '/barber_owner_home': (context) => PlaceholderScreen(title: 'Barber Owner Home'),
          '/barber_home': (context) => PlaceholderScreen(title: 'Barber Home'),
        },
      );
    }
  }
}

// Placeholder screen for testing navigation
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Logout'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}