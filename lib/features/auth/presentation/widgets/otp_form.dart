import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/home/HomePage.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/controllers/auth_controller.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final userId = args?['userId'];
    final email = args?['email'];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 48, 48, 48)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 40),
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter the verification code sent to\n$email',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _otpController,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: TextStyle(color: Colors.white54),
                      counterStyle: TextStyle(color: Colors.white70),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      setState(() => isLoading = true);
                      String otp = _otpController.text.trim();

                      if (otp.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter OTP"))
                        );
                        setState(() => isLoading = false);
                        return;
                      }

                      var response = await _verifyOTP(userId, otp);
                      // debugPrint("response $response");

                      if (response != null && response['access_token'] != null) {
                        final token = response['access_token'];
                        final user = JwtDecoder.decode(token);
                        
                        // Update auth state through the controller
                        await ref.read(authProvider.notifier).updateAuthState(user, token);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP Verified Successfully"))
                        );

                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid OTP"))
                        );
                      }
                      setState(() => isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement resend OTP
                    },
                    child: const Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _verifyOTP(String? userId, String otp) async {
    final ApiClient apiClient = ApiClient();

    final requestBody = {
      'userId': userId,
      'otp': otp,
    };

    try {
      final response = await apiClient.post(
        ApiConstants.registerVerifyEndpoint,
        requestBody,
      );

      if (response['access_token'] != null) {
        return response;
      } else {
        return null;
      }
    } catch (error) {
      print("Error during OTP verification: $error");
      return null;
    }
  }
}
