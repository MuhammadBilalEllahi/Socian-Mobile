import 'dart:convert';

import 'package:beyondtheclass/components/customSnackBar.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/otp_form.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/widgets/my_dropdown.dart';
import 'package:beyondtheclass/shared/widgets/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpForm extends StatefulWidget {
  final String role;
  const SignUpForm(this.role, {super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>(); // FormKey for validation
  final GlobalKey<FormFieldState<String>> _usernameKey =
      GlobalKey<FormFieldState<String>>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  String? selectedUniversity; // To store the selected value  ### _id
  String? selectedDepartment; // To store the selected value  ### _id
  String? selectedRegex;
  String? selectedDomain;
  bool isPasswordVisible = false; // Track password visibility
  List<Map<String, dynamic>> universities = [];
  List<Map<String, dynamic>> departmentsInSelectedUniversity = [];
  bool isLoading = true;
  final ApiClient apiClient = ApiClient();

  bool isUsernameTaken = false; // Flag to track if username is taken

  @override
  void initState() {
    super.initState();
    fetchUniversities();

    // Add listener to the username controller to check for uniqueness
    _usernameController.addListener(() {
      if (_usernameController.text.length >= 7) {
        checkUsernameAvailability(_usernameController.text);
      } else {
        setState(() {
          isUsernameTaken =
              false; // Reset flag if username is less than 7 characters
        });
      }
    });
  }

  void fetchUniversities() async {
    try {
      print(ApiConstants.universityAndCampusNames);
      final response =
          await apiClient.getList(ApiConstants.universityAndCampusNames);
      // print("A $apiClient");
      // print("A $response");
      setState(() {
        universities = (response)
            .map((uni) => {
                  'name': uni['name'],
                  '_id': uni['_id'],
                  'departments': uni['departments'],
                  'regex': uni['regex'],
                  'domain': uni['domain'],
                })
            .toList();

        print("fetching universities: $universities");
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching universities: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  FormFieldValidator<dynamic> emailValidator() {
    return (dynamic value) {
      if (value == null || value.isEmpty) {
        return 'Please enter an email';
      }

      // Regular expression for email validation
      final emailRegex =
          RegExp(selectedRegex ?? ''); // Fallback to empty string
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }

      return null; // Return null if valid
    };
  }

// Function to check username availability
  void checkUsernameAvailability(String username) async {
    try {
      final response = await apiClient
          .get(ApiConstants.usernames, queryParameters: {'username': username});
      print("REsponse $response ${response == true}");
      if (response == true) {
        setState(() {
          isUsernameTaken = true; // Set the flag for taken username
        });

// WidgetsBinding.instance.addPostFrameCallback((_) {
//     _usernameKey.currentState?.validate();
//   });
      } else {
        setState(() {
          isUsernameTaken = false; // Reset flag if username is available
        });
        // _usernameKey.currentState?.validate();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _usernameKey.currentState?.validate();
      });
    } catch (e) {
      print("Error checking username: $e");
    }
  }
  FormFieldValidator<dynamic> usernameValidator() {
    return (value) {
      // Check for empty value
      if (value == null || value.isEmpty) {
        return 'Username cannot be empty';
      }

      // Check for minimum length
      if (value.length < 8) {
        return 'Username must be at least 8 characters long';
      }

      // Check for whitespace
      if (value.contains(' ')) {
        return 'Username cannot contain spaces';
      }

      // Check for lowercase
      if (value.contains(RegExp(r'[A-Z]'))) {
        return 'Username must be lowercase';
      }

      // Check for numbers
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Username must contain at least one number';
      }

      // Check for valid characters
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
        return 'Username can only contain lowercase letters, numbers, and underscores';
      }

      // Check if username is taken
      if (isUsernameTaken) {
        return 'Username is already taken';
      }

      return null;
    };
  }

  void signupStudent() async {
    try {
      final universityDetails = selectedUniversity?.split('-');
      final universityId = universityDetails?[0];
      final campusId = universityDetails?[1];

      final requestBody = {
        'universityEmail': _emailController.text,
        'name': _nameController.text,
        'password': _passwordController.text,
        'username': _usernameController.text,
        'universityId': universityId,
        'campusId': campusId,
        'role': widget.role, // Change when needed (this is just an example rolee)
        'departmentId': selectedDepartment,
      };

      final response =
          await apiClient.post(ApiConstants.registerEndpoint, requestBody);

      print("Signup response: $response");

      final data = response;

// Extract userId from the redirectUrl
      final redirectUrl = data['redirectUrl'];
      final userId = redirectUrl.split('/otp/')[1].split('?')[0];

      final email = redirectUrl.split('/otp/')[1].split('?')[1].split('=')[1];

      print("object $email");
      // final data = response  ;
      // final userId = data['redirectUrl'].split('/otp/')[1].split('?')[0]; // Extract userId from URL

      // Navigate to OTP verification page
      Navigator.pushNamed(context, AppRoutes.otpScreen,
          arguments: {'userId': userId, 'email': email});
    } catch (e) {
      final error = e;
      showCustomSnackbar(title: 'Info', message: error.toString(), isError: true);


      print("ERROR WHILE SIGNING UP $e");
    }
  }

  void _signup() {
    print("FT ");
    if (_formKey.currentState?.validate() ?? false) {
      signupStudent();

      // Form is valid, proceed with signup logic
      print("Signing up with:");
      print("Name: ${_nameController.text}");
      print("Username: ${_usernameController.text}");
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");
      print("University: $selectedUniversity");
      print("Department: $selectedDepartment");
    } else {
      // If form is not valid, show an error or message
      print("Form is invalid");
      print("Signing up with:");
      print("Name: ${_nameController.text}");
      print("Username: ${_usernameController.text}");
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");
      print("University: $selectedUniversity");
      print("Department: $selectedDepartment");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyDropdownField<String>(
                value: selectedUniversity,
                items: universities,
                label: "Select University",
                validator: dropdownValidator(selectedUniversity, 'University'),
                onChanged: (value) {
                  setState(() {
                    selectedUniversity = value;
                    selectedDepartment = null;
                    final selectedUni = universities.firstWhere(
                        (uni) => uni['_id'] == value,
                        orElse: () => {'departments': []});

                    departmentsInSelectedUniversity =
                        List<Map<String, dynamic>>.from(
                            selectedUni['departments'] ?? []);

                    selectedRegex = selectedUni['regex'];
                  });
                },
              ),

              const SizedBox(height: 16),

              MyDropdownField<String>(
                value: selectedDepartment,
                items: departmentsInSelectedUniversity,
                label: "Select Department",
                validator: dropdownValidator(selectedDepartment, 'Department'),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
              ),

              // Full Name TextField
              MyTextField(
                  textEditingController: _nameController,
                  label: 'Full Name',
                  obscureTextBool: false,
                  focus: false,
                  validator: nameValidator()),

              // const SizedBox(height: 16),

              // Username TextField
              MyTextField(
                  customKey: _usernameKey,
                  textEditingController: _usernameController,
                  label: 'Choose a Username',
                  obscureTextBool: false,
                  focus: false,
                  validator: usernameValidator()),

              // const SizedBox(height: 16),
              // Institutional Email TextField
              MyTextField(
                  textEditingController: _emailController,
                  label: 'Your Instituitonal Email',
                  obscureTextBool: false,
                  focus: false,
                  validator: emailValidator()),

              MyTextField(
                  textEditingController: _passwordController,
                  label: 'Password',
                  obscureTextBool: !isPasswordVisible,
                  focus: false,
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
                  validator: passwordValidator()),

              const SizedBox(height: 10),

              // Sign Up Button
              //   Center(
              //     child: ElevatedButton(
              //       onPressed: signup,
              //       style: ButtonStyle(
              //         backgroundColor: WidgetStatePropertyAll<Color>(
              //           Colors.teal.shade800,
              //         ),
              //         foregroundColor:
              //             const WidgetStatePropertyAll<Color>(Colors.white),
              //         padding: const WidgetStatePropertyAll<EdgeInsets>(
              //           EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              //         ),
              //         shape: WidgetStatePropertyAll<OutlinedBorder>(
              //           RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //       child: const Text(
              //         "Sign Up",
              //         style: TextStyle(fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ),

              Center(
                child: GestureDetector(
                  onTap: _signup,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                    margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    decoration: BoxDecoration(
                      // color: const Color.fromARGB(255, 31, 31, 31),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 18, 18, 18),
                          Color.fromARGB(255, 0, 0, 0),
                          Color.fromARGB(255, 31, 31, 31)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.bottomRight,
                      ),

                      border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          width: 0.6),
                      // color: Colors.black.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        AppConstants.signUp,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

FormFieldValidator<dynamic> dropdownValidator(String? value, String fieldName) {
  return (value) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  };
}

FormFieldValidator<dynamic> nameValidator() {
  return (value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
  };
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
