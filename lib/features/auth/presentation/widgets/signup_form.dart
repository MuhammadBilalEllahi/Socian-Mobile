import 'package:flutter/material.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/presentation/PrivacyPolicyScreen.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/services/secure_storage_service.dart';
import 'package:socian/shared/widgets/my_dropdown.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';
import 'package:socian/shared/widgets/my_textfield.dart';

class SignUpForm extends StatefulWidget {
  final String role;
  const SignUpForm(this.role, {super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _usernameKey =
      GlobalKey<FormFieldState<String>>();

  final _emailController = TextEditingController();

  final _personalEmailController = TextEditingController();

  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _agreedToPolicy = false;

  String? selectedUniversity;
  String? selectedDepartment;
  String? selectedRegex;
  String? selectedDomain;
  bool isPasswordVisible = false;
  List<Map<String, dynamic>> universities = [];
  List<Map<String, dynamic>> departmentsInSelectedUniversity = [];
  bool isLoading = true;
  bool isSigningUp = false;
  final ApiClient apiClient = ApiClient();
  bool isUsernameTaken = false;

  void _cacheListeners() {
    _nameController.addListener(_cacheSignupData);
    _usernameController.addListener(_cacheSignupData);
    _emailController.addListener(_cacheSignupData);
    _personalEmailController.addListener(_cacheSignupData);
  }

  Future<void> _cacheSignupData() async {
    final storage = SecureStorageService.instance;
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    await storage.saveField('signup_name', _nameController.text);
    await storage.saveField('signup_username', _usernameController.text);
    await storage.saveField('signup_email', _emailController.text);
    await storage.saveField(
        'signup_personalEmail', _personalEmailController.text);
    if (selectedUniversity != null) {
      await storage.saveField('signup_university', selectedUniversity!);
    }
    if (selectedDepartment != null) {
      await storage.saveField('signup_department', selectedDepartment!);
    }
    await storage.saveField('signup_cachedTime', now);
  }

  Future<void> _restoreSignupData() async {
    final storage = SecureStorageService.instance;

    final time = await storage.getField('signup_cachedTime');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (time != null && now - int.parse(time) < 2 * 24 * 60 * 60 * 1000) {
      _nameController.text = (await storage.getField('signup_name')) ?? '';
      _usernameController.text =
          (await storage.getField('signup_username')) ?? '';
      _emailController.text = (await storage.getField('signup_email')) ?? '';
      _personalEmailController.text =
          (await storage.getField('signup_personalEmail')) ?? '';
      selectedUniversity = await storage.getField('signup_university');
      selectedDepartment = await storage.getField('signup_department');
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUniversities();

    _usernameController.addListener(() {
      if (_usernameController.text.length >= 7) {
        checkUsernameAvailability(_usernameController.text);
      } else {
        setState(() {
          isUsernameTaken = false;
        });
      }
    });
    _restoreSignupData();
    _cacheListeners();
  }

  void fetchUniversities() async {
    try {
      final response =
          await apiClient.getList(ApiConstants.universityAndCampusNames);
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
        isLoading = false;
      });
    } catch (e) {
      // debugPrint("Error fetching universities: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  FormFieldValidator<dynamic> personalEmailValidator() {
    return (dynamic value) {
      if (AppRoles.alumni != widget.role) {
        return null; // Skip validation for non-alumni roles
      }
      if (value == null || value.isEmpty) {
        return 'Please enter an email';
      }

      return null;
    };
  }

  FormFieldValidator<dynamic> emailValidator() {
    return (dynamic value) {
      if (value == null || value.isEmpty) {
        return 'Please enter an email';
      }

      if (AppRoles.student == widget.role) {
        final emailRegex = RegExp(selectedRegex ?? '');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
      } else if (AppRoles.teacher == widget.role) {
        final result = value
            .toString()
            .split('@')[1]
            .allMatches(selectedDomain.toString());
        if (result.isEmpty) {
          return 'Please enter a valid email address';
        }
      }

      return null;
    };
  }

  void checkUsernameAvailability(String username) async {
    try {
      final response = await apiClient
          .get(ApiConstants.usernames, queryParameters: {'username': username});
      if (response == true) {
        setState(() {
          isUsernameTaken = true;
        });
      } else {
        setState(() {
          isUsernameTaken = false;
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _usernameKey.currentState?.validate();
      });
    } catch (e) {
      // debugPrint("Error checking username: $e");
    }
  }

  FormFieldValidator<dynamic> usernameValidator() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Username cannot be empty';
      }
      if (value.length < 8) {
        return 'Username must be at least 8 characters long';
      }
      if (value.contains(' ')) {
        return 'Username cannot contain spaces';
      }
      if (value.contains(RegExp(r'[A-Z]'))) {
        return 'Username must be lowercase';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Username must contain at least one number';
      }
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
        return 'Username can only contain lowercase letters, numbers, and underscores';
      }
      if (isUsernameTaken) {
        return 'Username is already taken';
      }
      return null;
    };
  }

  Future<void> signupStudent() async {
    if (!_agreedToPolicy) {
      showSnackbar(context, 'You must agree to the privacy policy to continue.',
          isError: true);
      return;
    }

    if (isSigningUp) return;

    setState(() {
      isSigningUp = true;
    });

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
        'role': widget.role,
        'departmentId': selectedDepartment,
        'agreedToPolicy': _agreedToPolicy,
      };

      if (AppRoles.alumni == widget.role) {
        requestBody['personalEmail'] = _personalEmailController.text;
      }
      final response =
          await apiClient.post(ApiConstants.registerEndpoint, requestBody);

      final data = response;
      final redirectUrl = data['redirectUrl'];
      final userId = redirectUrl.split('/otp/')[1].split('?')[0];
      final email = redirectUrl.split('/otp/')[1].split('?')[1].split('=')[1];
      if (mounted) {
        showSnackbar(context, "Sign up successful! Please verify your email.");

        Navigator.pushNamed(context, AppRoutes.otpScreen,
            arguments: {'userId': userId, 'email': email});
      }

      await SecureStorageService.instance.clearSignupFields();
    } catch (e) {
      if (mounted) {
        showSnackbar(context, e.toString(), isError: true);

        // debugPrint("Error during signup: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isSigningUp = false;
        });
      }
    }
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      signupStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyDropdownField<String>(
                isLoading: isLoading,
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

                    selectedDomain = selectedUni['domain'];
                    selectedRegex = selectedUni['regex'];
                  });
                  _cacheSignupData();
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
              MyTextField(
                  textEditingController: _nameController,
                  label: 'Full Name',
                  obscureTextBool: false,
                  focus: false,
                  validator: nameValidator()),
              MyTextField(
                  customKey: _usernameKey,
                  textEditingController: _usernameController,
                  label: 'Choose a Username',
                  obscureTextBool: false,
                  focus: false,
                  validator: usernameValidator()),
              if (widget.role == AppRoles.alumni) ...[
                MyTextField(
                    textEditingController: _personalEmailController,
                    label: 'Your Personal Email',
                    obscureTextBool: false,
                    focus: false,
                    validator: personalEmailValidator()),
              ],
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
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  validator: passwordValidator()),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Checkbox(
                    activeColor: isDarkMode
                        ? const Color.fromARGB(255, 138, 138, 138)
                        : const Color.fromARGB(255, 20, 20, 20),
                    checkColor: isDarkMode
                        ? const Color.fromARGB(255, 20, 20, 20)
                        : const Color.fromARGB(255, 138, 138, 138),
                    visualDensity: VisualDensity.comfortable,
                    value: _agreedToPolicy,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreedToPolicy = value ?? false;
                      });
                    },
                  ),
                  const Text('I agree to the '),
                  GestureDetector(
                    onTap: () async {
                      // showPrivacyPolicyBottomSheet(context),
                      // Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen()),
                      );

                      if (result == true) {
                        setState(() {
                          _agreedToPolicy = true;
                        });
                      }
                    },
                    child: Text(
                      'privacy policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: isDarkMode
                            ? const Color.fromARGB(255, 138, 138, 138)
                            : const Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: isSigningUp ? null : _signup,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                    margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isSigningUp
                              ? Colors.grey
                              : const Color.fromARGB(255, 18, 18, 18),
                          isSigningUp
                              ? Colors.grey.shade700
                              : const Color.fromARGB(255, 0, 0, 0),
                          isSigningUp
                              ? Colors.grey.shade600
                              : const Color.fromARGB(255, 31, 31, 31)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          width: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: isSigningUp
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
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
