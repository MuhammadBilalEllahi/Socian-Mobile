import 'dart:developer';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';
import 'package:socian/shared/widgets/my_textfield.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController oldPasswordEditingController = TextEditingController();
  final TextEditingController newPasswordEditingController = TextEditingController();
  final TextEditingController repeatNewPasswordEditingController = TextEditingController();

  bool obscureTextOld = true;
  bool obscureTextNew = true;
  bool obscureTextRepeatNew = true;
  bool isLoading = false;

  final _apiClient = ApiClient();

  Future<void> _changePassword() async {
    
    if(globalKey.currentState?.validate() ?? false){
        try {
          setState(() {
      isLoading=true;
    });
      final oldPassword = oldPasswordEditingController.text.trim();
      final newPassword = newPasswordEditingController.text.trim();
      final repeatPassword = repeatNewPasswordEditingController.text.trim();

      if (oldPassword.isEmpty || newPassword.isEmpty || repeatPassword.isEmpty) {
        log("Please fill all fields");
        showSnackbar(context, "Please fill all fields", isError: true);
        return;
      }

      if (newPassword != repeatPassword) {
        log("Passwords do not match");
        showSnackbar(context, "Passwords do not match", isError: true);
        return;
      }

      if (newPassword == oldPassword) {
        log("New password cannot be same as old");
              showSnackbar(context, "New password cannot be same as old", isError: true);

        return;
      }
      

      final response = await _apiClient.put('/api/auth/reset-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      log("RESPONSE: $response");
      if(response['message'] != null){
        String message = response['message'];
        showSnackbar(context, message, isError: false);
      }

      oldPasswordEditingController.text = '';
      newPasswordEditingController.text = '';
      repeatNewPasswordEditingController.text = '';

    } catch (e) {
      log("Error changing password: $e");
      showSnackbar(context, e.toString(), isError: true);
    }finally{
      setState(() {
      isLoading=false;
    });
    }
      }
    
  }
  final globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'Change Password',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: Form(
        key: globalKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Secure your account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              MyTextField(
                textEditingController: oldPasswordEditingController,
                label: 'Old Password',
                obscureTextBool: obscureTextOld,
                validator: null,
                focus: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureTextOld ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                  onPressed: () => setState(() => obscureTextOld = !obscureTextOld),
                ),
              ),
              const SizedBox(height: 16),
              MyTextField(
                textEditingController: newPasswordEditingController,
                label: 'New Password',
                obscureTextBool: obscureTextNew,
                validator: passwordValidator(),
                focus: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureTextNew ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                  onPressed: () => setState(() => obscureTextNew = !obscureTextNew),
                ),
              ),
              const SizedBox(height: 16),
              MyTextField(
                textEditingController: repeatNewPasswordEditingController,
                label: 'Repeat New Password',
                obscureTextBool: obscureTextRepeatNew,
                validator: null,
                focus: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureTextRepeatNew ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                  onPressed: () => setState(() => obscureTextRepeatNew = !obscureTextRepeatNew),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading ? 
                CircularProgressIndicator():
                 const  Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


FormFieldValidator<dynamic> passwordValidator() {
  return (value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  };
}

