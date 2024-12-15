// import 'package:flutter/material.dart';
//
// class signup_form extends StatefulWidget {
//   const signup_form({super.key});
//
//   @override
//   State<signup_form> createState() => _signup_formState();
// }
//
// class _signup_formState extends State<signup_form> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final nameController = TextEditingController();
//   final usernameController = TextEditingController();
//
//   void signup(){
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextField(
//             controller: nameController,
//             decoration: const InputDecoration(labelText: "Select University",labelStyle: TextStyle(color: Colors.white)),
//           ),
//           TextField(
//             controller: nameController,
//             decoration: const InputDecoration(labelText: "Full Name",labelStyle: TextStyle(color: Colors.white)),
//           ),
//           TextField(
//             controller: usernameController,
//             decoration: const InputDecoration(labelText: "Choose a Username",labelStyle: TextStyle(color: Colors.white)),
//           ),
//           TextField(
//             controller: emailController,
//             decoration: const InputDecoration(labelText: "Your Institutional Email",labelStyle: TextStyle(color: Colors.white)),
//             obscureText: true,
//           ),
//           TextField(
//             controller: passwordController,
//             decoration: const InputDecoration(labelText: "Password",labelStyle: TextStyle(color: Colors.white)),
//             obscureText: true,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(onPressed: signup, child: const Text("Sign Up",style: TextStyle(fontWeight: FontWeight.bold),),
//               style: ButtonStyle(
//                 backgroundColor: WidgetStatePropertyAll<Color>(Colors.teal.shade800),
//                 foregroundColor:  WidgetStatePropertyAll<Color>(Colors.white),
//
//               )
//           ),
//         ],
//       ),
//     );
//   }
// }

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
            obscureText: false,
          ),
          const SizedBox(height: 16),

          // Password TextField
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.white),
            ),
            obscureText: true,
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
                backgroundColor:
                WidgetStatePropertyAll<Color>(Colors.teal.shade800),
                foregroundColor: const WidgetStatePropertyAll<Color>(
                    Colors.white),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                shape: WidgetStatePropertyAll<OutlinedBorder>(
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

