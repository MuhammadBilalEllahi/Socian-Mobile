import 'dart:math';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/login_form.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAppNameAnimation;
  late Animation<double> _scaleAppNameAnimation;
  late Animation<double> _fadeSubtitleAnimation;
  late Animation<double> _pulseFormAnimation;
  late Animation<double> _fadeSignUpAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _fadeAppNameAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _scaleAppNameAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _fadeSubtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.7, curve: Curves.easeInOut)),
    );
    _pulseFormAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.85), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.85, end: 1.0), weight: 25),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );
    _fadeSignUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authController = ref.watch(authProvider.notifier);

    if (authState.user != null) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.teal,
        child: Stack(
          children: [
            Positioned.fill(child: AnimatedBackgroundParticles()),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 120),
                            FadeTransition(
                              opacity: _fadeAppNameAnimation,
                              child: ScaleTransition(
                                scale: _scaleAppNameAnimation,
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Colors.white, Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    tileMode: TileMode.mirror,
                                  ).createShader(bounds),
                                  child: Text(
                                    AppConstants.appName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _fadeSubtitleAnimation,
                              child: Text(
                                "Login to access your account",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 40),
                            AnimatedBuilder(
                              animation: _pulseFormAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _pulseFormAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15 * _pulseFormAnimation.value),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: const LoginForm(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            FadeTransition(
                              opacity: _fadeSignUpAnimation,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.roleSelection,
                                      );
                                    },
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            color: Colors.blueAccent.withOpacity(0.5),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
      final x = (size.width * (i / 20)) + (sin(animationValue * 2 * pi + i) * 50);
      final y = (size.height * (i / 20)) + (cos(animationValue * 2 * pi + i) * 50);
      canvas.drawCircle(Offset(x, y), 5 + (sin(animationValue + i) * 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
