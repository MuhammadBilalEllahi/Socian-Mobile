import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
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

  // State for toggling password visibility
  bool isPasswordVisible = false;

  void _login() {
    print(
        "1 - File: login_form.dart - This is credentials: ${emailController.text} and ${passwordController.text}");
    ref.read(authProvider.notifier).login(
          emailController.text,
          passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email/Username",
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
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
            onTap: _login,
            child: Container(
              width: MediaQuery.of(context).size.width / 2.2,
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
              margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
              decoration: BoxDecoration(
                // color: const Color.fromARGB(255, 31, 31, 31),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 18, 18, 18),
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromARGB(255, 31, 31, 31)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomRight,
                ),

                border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, 1), width: 0.6),
                // color: Colors.black.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  AppConstants.login,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
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
