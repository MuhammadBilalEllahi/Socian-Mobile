import 'package:beyondtheclass/UI Pages/HomePage.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  // This will receive the userId passed from the registration screen
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    print("DATA $args");
    final userId = args?['userId'];
    final email = args?['email'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter OTP for User ID: $email'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
              maxLength: 6, // Assuming OTP is 6 digits
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Get the OTP from the controller
                String otp = _otpController.text.trim();

                if (otp.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter OTP")));
                  return;
                }

                // Assuming you send the OTP along with the userId to verify
                var response = await _verifyOTP(userId, otp);

                if (response != null && response['access_token'] != null) {
                  // Store the access token in secure storage
                  final token = response['access_token'];
                  final user = JwtDecoder.decode(token);
                  await SecureStorageService.instance.saveToken(token);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP Verified Successfully")));

                  // Navigate to the home screen or wherever needed
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid OTP")));
                }
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }

  // Simulating OTP verification process
  Future<Map<String, dynamic>?> _verifyOTP(String? userId, String otp) async {
    final ApiClient apiClient = ApiClient();

    final requestBody = {
      'userId': userId,
      'otp': otp,
    };

    try {
      final response = await apiClient.post(
        ApiConstants.registerVerifyEndpoint, // Replace with actual endpoint
        requestBody,
      );

      // Check if the response contains an access_token and return it
      if (response['access_token'] != null) {
        return response;
      } else {
        return null; // Invalid response or no token found
      }
    } catch (error) {
      // Handle API request error
      print("Error during OTP verification: $error");
      return null;
    }
  }
}
