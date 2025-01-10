import 'dart:async';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:beyondtheclass/UI%20Pages/HomePage.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/RoleSelectionPage.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/student_signupScreen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _moveToTop = false;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Start the fade animation
    _animationController.forward();

    // Trigger the upward movement after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _moveToTop = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cuilahore.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Animated Column
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            top: _moveToTop ? 50 : MediaQuery.of(context).size.height / 2 - 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Beyond The Class",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Discover New Horizons\nLook Beyond the Class",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Horizontal Scrolling Containers
          if (_moveToTop)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildInfoContainer(
                          'assets/images/cuilahore.jpg', // Image path
                          'Explore the new features of our app that make your life easier.',
                          Colors.teal,
                        ),
                        _buildInfoContainer(
                          'assets/images/anime.png', // Image path
                          'Explore the new features of our app that make your life easier.',
                          Colors.teal,
                        ),
                        _buildInfoContainer(
                          'assets/images/profilepic.jpg', // Image path
                          'Explore the new features of our app that make your life easier.',
                          Colors.teal,
                        ),
                        _buildInfoContainer(
                          'assets/images/cuilahore.jpg', // Image path
                          'Explore the new features of our app that make your life easier.',
                          Colors.teal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // signup
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                          );
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade900,
                            borderRadius: BorderRadius.circular(12),

                          ),
                          child: Center(
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      // login
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  AuthScreen()),
                          );
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build individual info containers
  Widget _buildInfoContainer(String imagePath, String paragraph, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8.0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the image, taking half the size of the parent container
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.75 * 0.8, // 50% of the container's width
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Display the promotional paragraph
          Text(
            paragraph,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16, // Text size for the paragraph
              fontWeight: FontWeight.w500,
              height: 1.5, // Line height for better readability
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


}

