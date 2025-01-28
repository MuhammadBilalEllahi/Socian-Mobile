

import 'package:beyondtheclass/UI%20Pages/HomePage.dart';
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

  void login() {
    print("1 - File: login_form.dart - This is credentials: ${emailController.text} and ${passwordController.text}");
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

    // final authState = ref.watch(authProvider);
    // final authController = ref.watch(authProvider.notifier);

    // print("authController ${authController.authUseCases}");
    // if (authState.user != null) {
    //   Future.microtask(() {
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => const HomePage()),
    //     );
    //   });
    // }

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
          ElevatedButton(
            onPressed: login,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Colors.teal.shade800),
              foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
