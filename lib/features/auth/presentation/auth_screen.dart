import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/login_form.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authController = ref.watch(authProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    print("authController ${authController.authUseCases}");

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromARGB(255, 48, 48, 48)
                  ]
                : [
                    Color.fromARGB(255, 240, 240, 240),
                    Color.fromARGB(255, 255, 255, 255)
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        Icon(
                          Icons.school,
                          size: 80,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Login to access your account",
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const LoginForm(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.roleSelection);
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }
}
