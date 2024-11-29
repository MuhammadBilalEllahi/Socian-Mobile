import 'package:beyondtheclass/UI%20Pages/HomePage.dart';
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

    print("authController ${authController.authUseCases}");
    if (authState.user != null) {
      Future.microtask(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage()));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const LoginForm(),
    );
  }
}
