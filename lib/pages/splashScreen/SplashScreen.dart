import 'dart:async';
import 'dart:math';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/splashScreen/components/GoogleButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _textAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _moveToTop = false;

  @override
  void initState() {
    super.initState();

    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500), // Increased to 3s for 3 words
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    Future.delayed(const Duration(seconds: 4), () { // Adjusted to 4s to see full animation
      setState(() => _moveToTop = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.watch(authProvider);
    if (authState.user != null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, AppRoutes.home));
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null) Navigator.pushReplacementNamed(context, AppRoutes.home);
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.teal,
            child: Stack(
              children: [
                Positioned.fill(child: AnimatedBackgroundParticles()),
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            top: _moveToTop ? 80 : MediaQuery.of(context).size.height / 2 - 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildAnimatedAppName(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appSloganNewLine,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (_moveToTop)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 140,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildInfoContainer(AppAssets.splashBackground2, 'Student', 'Empower Your Future', Colors.purple.shade800),
                        _buildInfoContainer(AppAssets.anime, 'Teacher', 'Inspire the Next Generation', Colors.blue.shade800),
                        _buildInfoContainer(AppAssets.profilePic, 'Alumni', 'Connect and Thrive', Colors.teal.shade800),
                        _buildInfoContainer(AppAssets.splashBackground2, 'Organization', 'Build Communities', Colors.indigo.shade800),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton(
                            text: AppConstants.signUp,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.roleSelection),
                            gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
                          ),
                          const SizedBox(width: 16),
                          _buildButton(
                            text: AppConstants.login,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.authScreen),
                            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.9), Colors.grey.shade300]),
                            textColor: Colors.black87,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const GoogleButton(),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }





  // Fixed to animate all words in "Beyond The Class"
Widget _buildAnimatedAppName() {
  String appName = 'Beyond The Class'; 
  List<String> words = appName.split(' '); 
  double totalDuration = 3.5; // Total animation duration in seconds

  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      colors: [Colors.white, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        final wordDelay = (index * (totalDuration * 0.15)) / words.length; // Delays each word slightly

        return AnimatedBuilder(
          animation: _textAnimationController,
          builder: (context, child) {
            final animationValue = (_textAnimationController.value - wordDelay)
                .clamp(0.0, 1.0); // Ensures full animation
            final progress = Curves.easeOutCubic.transform(animationValue);

            return Transform.translate(
              offset: Offset(0, -30 * (1 - progress)), // Moves up smoothly
              child: Opacity(
                opacity: progress,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    word,
                    style: GoogleFonts.cinzel(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    ),
  );
}








  Widget _buildInfoContainer(String imagePath, String title, String subtitle, Color baseColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor.withOpacity(0.9), baseColor.withOpacity(0.6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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

  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    required LinearGradient gradient,
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Particle Background Widget (unchanged)
class AnimatedBackgroundParticles extends StatefulWidget {
  @override
  _AnimatedBackgroundParticlesState createState() => _AnimatedBackgroundParticlesState();
}

class _AnimatedBackgroundParticlesState extends State<AnimatedBackgroundParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20)) + (sin(animationValue * 2 * 3.14 + i) * 50);
      final y = (size.height * (i / 20)) + (cos(animationValue * 2 * 3.14 + i) * 50);
      canvas.drawCircle(Offset(x, y), 5 + (sin(animationValue + i) * 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}










