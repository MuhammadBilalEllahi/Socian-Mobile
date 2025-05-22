import 'dart:async';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/domain/auth_state.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/splashScreen/components/GoogleButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _moveToTop = false;
  bool _isDarkMode = true; // Add theme state

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.forward();
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                colors: isDarkMode
                    ? [
                        const Color.fromARGB(255, 19, 19, 19).withOpacity(0.9),
                        const Color.fromARGB(255, 26, 26, 26).withOpacity(1),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.grey[100]!.withOpacity(1),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            top:
                _moveToTop ? 120 : MediaQuery.of(context).size.height / 2 - 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    letterSpacing: 1.2,
                    fontFamily: 'sans-serif',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppConstants.appSloganNewLine,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
                        AppAssets.splashBackground2,
                        'Student - Individuals',
                        'Hic venit exemplum illud',
                        isDarkMode
                            ? const Color.fromARGB(255, 31, 31, 31)
                            : Colors.grey[200]!,
                      ),
                      _buildInfoContainer(
                        AppAssets.anime,
                        'Teacher - Individuals',
                        'Hic venit exemplum illud',
                        isDarkMode
                            ? const Color.fromARGB(255, 31, 31, 31)
                            : Colors.grey[200]!,
                      ),
                      _buildInfoContainer(
                        AppAssets.profilePic,
                        'Alumni - Individuals',
                        'Hic venit exemplum illud',
                        isDarkMode
                            ? const Color.fromARGB(255, 31, 31, 31)
                            : Colors.grey[200]!,
                      ),
                      _buildInfoContainer(
                        AppAssets.splashBackground2,
                        'Organization - Individuals',
                        'Hic venit exemplum illud',
                        isDarkMode
                            ? const Color.fromARGB(255, 31, 31, 31)
                            : Colors.grey[200]!,
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
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color.fromARGB(255, 139, 139, 139),
                                width: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                AppConstants.signUp,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.authScreen);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.2,
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                            margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 244, 244, 244)
                                      .withOpacity(0.88)
                                  : Colors.black87.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                AppConstants.login,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isDarkMode
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const GoogleButton(),
                  ],
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(
    String imagePath,
    String paragraphTitle,
    String paragraph,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.5),
            color.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 7.0,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.70 * 0.8,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
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
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  paragraph,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
