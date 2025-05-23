import 'dart:async';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/presentation/widgets/login_form.dart';
import 'package:socian/features/auth/presentation/NewPasswordScreen.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authController = ref.watch(authProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: isDarkMode ? Colors.blue[200] : Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
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

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  bool isOtpSent = false;
  int countdown = 60;
  Timer? timer;
  bool isResendEnabled = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      isResendEnabled = false;
      countdown = 60;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
        if (countdown <= 0) {
          isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> sendOtp(String email) async {
    setState(() => isLoading = true);
    try {
      final apiClient = ApiClient();
      final endpoint = '/api/auth/forgot-password';
      final fullUrl = '${ApiConstants.baseUrl}$endpoint';

      //debugPrint('Making forgot password request to: $fullUrl');
      //debugPrint('Request payload: {"email": "$email"}');

      final response = await apiClient.put(
        endpoint,
        {'email': email},
        headers: {
          'Content-Type': 'application/json',
          'x-platform': 'app',
        },
      );

      //debugPrint('Forgot password response: $response');

      if (mounted) {
        setState(() {
          isOtpSent = true;
          startTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on ApiException catch (e) {
      //debugPrint('Forgot password API error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      //debugPrint('Unexpected error in forgot password: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    setState(() => isLoading = true);
    try {
      final apiClient = ApiClient();
      final endpoint = '/api/auth/verify/otp/password';
      final fullUrl = '${ApiConstants.baseUrl}$endpoint';

      //debugPrint('Making OTP verification request to: $fullUrl');
      //debugPrint('Request payload: {"email": "$email", "otp": "$otp"}');

      final response = await apiClient.post(
        endpoint,
        {
          'email': email,
          'otp': otp,
        },
        headers: {
          'Content-Type': 'application/json',
          'x-platform': 'app',
        },
      );

      //debugPrint('OTP verification response: $response');

      final token = response['token'];
      if (mounted) {
        // Close dialog and navigate in a single frame to avoid context issues
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                token: token,
                email: email,
              ),
            ),
          );
        });
      }
    } on ApiException catch (e) {
      //debugPrint('OTP verification error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      //debugPrint('Unexpected error in OTP verification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        isOtpSent ? "Verify OTP" : "Forgot Password",
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isOtpSent
                ? "Enter the OTP sent to ${emailController.text}"
                : "Enter your email to receive a password reset OTP",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          if (!isOtpSent)
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          if (isOtpSent)
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: "OTP",
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              keyboardType: TextInputType.number,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: isDarkMode ? Colors.blue[200] : Colors.blue,
            ),
          ),
        ),
        if (!isOtpSent)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.blue[800] : Colors.blue,
            ),
            onPressed: isLoading
                ? null
                : () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid email address')),
                        );
                      }
                      return;
                    }
                    await sendOtp(email);
                  },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Send OTP"),
          ),
        if (isOtpSent) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.blue[800] : Colors.blue,
            ),
            onPressed: isLoading
                ? null
                : () async {
                    final otp = otpController.text.trim();
                    if (otp.isEmpty || !RegExp(r'^\d{6}$').hasMatch(otp)) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid 6-digit OTP')),
                        );
                      }
                      return;
                    }
                    await verifyOtp(emailController.text.trim(), otp);
                  },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Verify OTP"),
          ),
          TextButton(
            onPressed: isResendEnabled && !isLoading
                ? () async {
                    final email = emailController.text.trim();
                    await sendOtp(email);
                  }
                : null,
            child: Text(
              isResendEnabled
                  ? "Resend OTP"
                  : "Resend OTP (${countdown}s)",
              style: TextStyle(
                color: isResendEnabled
                    ? (isDarkMode ? Colors.blue[200] : Colors.blue)
                    : (isDarkMode ? Colors.grey : Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
  }
}























