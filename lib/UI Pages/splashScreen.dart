
import 'dart:async';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:beyondtheclass/UI%20Pages/HomePage.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay splash logic for smooth transition
    Future.delayed(const Duration(seconds: 6), _checkAuthentication);
  }

  Future<void> _checkAuthentication() async {
    // Access authentication state
    final authState = ref.read(authProvider);
    final authController = ref.read(authProvider.notifier);

    if (authState.user != null) {
      // Navigate to HomePage if the user is authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Navigate to AuthScreen if the user is not authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
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
            colors: [Colors.teal.shade900, Colors.tealAccent.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.school,
                size: 120.0,
                // color: Colors.teal.shade600,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "Beyond The Class",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  // color: Colors.teal.shade900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Discover New Horizons, Look Beyond the Class",  textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  // color: Colors.teal.shade900,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,

                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
