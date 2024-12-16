import 'package:flutter/material.dart';

class signup_form extends StatefulWidget {
  const signup_form({super.key});

  @override
  State<signup_form> createState() => _signup_formState();
}

class _signup_formState extends State<signup_form> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  String? selectedUniversity; // To store the selected value
  bool isPasswordVisible = false; // Track password visibility

  void signup() {
    // Implement signup logic here
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Menu
          DropdownButtonFormField<String>(
            value: selectedUniversity,
            items: [
              DropdownMenuItem(
                value: 'COMSATS Lahore Campus',
                child: Text("COMSATS Lahore Campus"),
              ),
              DropdownMenuItem(
                value: 'FAST Lahore',
                child: Text("FAST Lahore"),
              ),
              DropdownMenuItem(
                value: 'NUST Islamabad',
                child: Text("NUST Islamabad"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedUniversity = value!;
              });
            },
            decoration: InputDecoration(
              labelText: "Select University",
              labelStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.teal.shade800.withOpacity(0.2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade800, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.teal.shade800, // Dropdown menu color
          ),
          const SizedBox(height: 16),

          // Full Name TextField
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          // Username TextField
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: "Choose a Username",
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          // Institutional Email TextField
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Your Institutional Email",
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          // Password TextField with Toggle Visibility
          TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible, // Toggle visibility
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility // Open eye icon
                      : Icons.visibility_off, // Closed eye icon
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible; // Toggle state
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sign Up Button
          Center(
            child: ElevatedButton(
              onPressed: signup,
              child: const Text(
                "Sign Up",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                  Colors.teal.shade800,
                ),
                foregroundColor:
                const MaterialStatePropertyAll<Color>(Colors.white),
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                shape: MaterialStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
