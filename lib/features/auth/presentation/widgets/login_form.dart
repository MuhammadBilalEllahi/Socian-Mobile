import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/widgets/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // State for toggling password visibility
  bool isPasswordVisible = false;

  void _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).login(
        context,
            emailController.text.trim(),
            passwordController.text,
          );

        

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Login successful!'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } catch (e) {
              // showSnackbar(context, e.toString(), isError: true);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(e.toString()),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final gradientColors = isDarkMode
        ? [
            Color.fromARGB(255, 18, 18, 18),
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 31, 31, 31)
          ]
        : [
            Color.fromARGB(255, 240, 240, 240),
            Color.fromARGB(255, 220, 220, 220),
            Color.fromARGB(255, 200, 200, 200)
          ];

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.user != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: textColor),
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Email/Username",
              labelStyle: TextStyle(color: textColor),
            ),
          ),
          TextField(
            style: TextStyle(color: textColor),
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: textColor),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: textColor,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isLoading ? null : _login,
            child: Container(
              width: MediaQuery.of(context).size.width / 2.2,
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
              margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: isDarkMode
                        ? const Color.fromRGBO(255, 255, 255, 1)
                        : const Color.fromRGBO(0, 0, 0, 0.2),
                    width: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Text(
                        AppConstants.login,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
