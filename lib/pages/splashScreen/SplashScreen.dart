import 'dart:async';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/splashScreen/components/GoogleButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const SplashScreen({Key? key}) : super(key: key);

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.watch(authProvider);

    if (authState.user != null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    return Scaffold(
      body: Stack(
        children: [


          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 19, 19, 19).withValues(alpha: 0.9),
                  const Color.fromARGB(255, 26, 26, 26).withValues(alpha: 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Animated Column
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            top:
                _moveToTop ? 120 : MediaQuery.of(context).size.height / 2 - 100,
            left: 0,
            right: 0,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(234, 255, 255, 255),
                      letterSpacing: 1.2,
                      fontFamily: 'sans-serif'),
                ),
                SizedBox(height: 10),
                Text(
                  AppConstants.appSloganNewLine,
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
              top: MediaQuery.of(context).size.height / 2 - 120,
              left: 0,
              right: 0,
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildInfoContainer(
                        AppAssets.splashBackground2, // Image path
                        'Student - Individulas',
                        'Love me like you do, what are you waiting for',
                        const Color.fromARGB(255, 31, 31, 31),
                      ),
                      _buildInfoContainer(
                        AppAssets.anime, // Image path
                        'Teacher - Individulas',
                        'Love me like you do, what are you waiting for',
                        const Color.fromARGB(255, 31, 31, 31),
                      ),
                      _buildInfoContainer(
                        AppAssets.profilePic, // Image path
                        'Alumni - Individulas',
                        'Love me like you do, what are you waiting for',
                        const Color.fromARGB(255, 31, 31, 31),
                      ),
                      _buildInfoContainer(
                        AppAssets.splashBackground2, // Image path
                        'Organization - Individulas',
                        'Love me like you do, what are you waiting for',
                        const Color.fromARGB(255, 31, 31, 31),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // signup
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.roleSelection);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.2,
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                            margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  width: 0.6),
                              // color: Colors.black.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text(
                                AppConstants.signUp,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 10,),
                        // login
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.authScreen);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.2,
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                            margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 244, 244, 244)
                                  .withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text(
                                AppConstants.login,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF121212),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const GoogleButton()
                    ],
                )
              ]),
            ),
        ],
      ),
    );
  }

  // Helper method to build individual info containers
  Widget _buildInfoContainer(
    String imagePath,
    String paragraphTitle,
    String paragraph,
    Color color,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      // padding: const EdgeInsets.fromLTRB(2  ,5 ,2 ,5),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 7.0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the image, taking half the size of the parent container
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width *
                0.70 *
                0.8, // 50% of the container's width
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  paragraphTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Text size for the paragraph
                    fontWeight: FontWeight.bold,
                    height: 1.5, // Line height for better readability
                  ),
                  textAlign: TextAlign.center,
                ),

                Text(
                  paragraph,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16, // Text size for the paragraph
                    fontWeight: FontWeight.w700,
                    height: 1.5, // Line height for better readability
                  ),
                  textAlign: TextAlign.center,
                ),
                // Display the promotional paragraph
              ],
            ),
          ),
        ],
      ),
    );
  }
}
