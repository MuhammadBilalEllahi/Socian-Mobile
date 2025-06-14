import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/presentation/alumni/UploadCardPage.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final userId = args?['userId'];
    final email = args?['email'];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color.fromARGB(255, 0, 0, 0),
                    const Color.fromARGB(255, 48, 48, 48)
                  ]
                : [
                    const Color.fromARGB(255, 240, 240, 240),
                    const Color.fromARGB(255, 255, 255, 255)
                  ],
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
                  icon: Icon(Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 40),
                Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please enter the verification code sent to\n$email',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _otpController,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 20),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black38),
                      counterStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54),
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            String otp = _otpController.text.trim();

                            if (otp.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Please enter OTP")));
                              setState(() => isLoading = false);
                              return;
                            }

                            var response = await _verifyOTP(userId, otp);

                            if (response != null &&
                                response['access_token'] != null) {
                              final token = response['access_token'];
                              final user = JwtDecoder.decode(token);

                              await ref
                                  .read(authProvider.notifier)
                                  .updateAuthState(user, token);

                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("OTP Verified Successfully")));

                              if (user['role'] == AppRoles.alumni) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const UploadCardPage()));
                                // Navigator.pushReplacementNamed(
                                //     context, AppRoutes.alumniUploadCard);
                              } else {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.home);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid OTP")));
                            }
                            setState(() => isLoading = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: isDarkMode ? Colors.black87 : Colors.white,
                          )
                        : Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.black87 : Colors.white,
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
                    child: Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54),
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
      // debugPrint("Error during OTP verification: $error");
      return null;
    }
  }
}
