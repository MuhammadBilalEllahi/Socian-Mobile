import 'package:beyondtheclass/UI%20Pages/HomePage.dart';
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

  

  void login() {
        print("1 - File: login_form.dart - This is credentials: ${emailController.text} and ${passwordController.text}");
    ref.read(authProvider.notifier).login(
          emailController.text,
          passwordController.text,
        );
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }
  

  @override
  Widget build(BuildContext context) {
      final authState = ref.watch(authProvider);
     final authController = ref.watch(authProvider.notifier);

    print("authController ${authController.authUseCases}");
    if (authState.user != null) {
      Future.microtask(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomePage()));
      });
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email",labelStyle: TextStyle(color: Colors.white)),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "Password",labelStyle: TextStyle(color: Colors.white)),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: login, child: const Text("Login",style: TextStyle(fontWeight: FontWeight.bold),),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.teal.shade800),
                foregroundColor:  WidgetStatePropertyAll<Color>(Colors.white),

              )
          ),
        ],
      ),
    );
  }
}
