import 'dart:developer';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/controllers/auth_controller.dart';
import 'package:beyondtheclass/features/auth/data/auth_data_source.dart';
import 'package:beyondtheclass/features/auth/domain/auth_usecase.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/profile/settings/personalInfo/ChangePassword.dart';
import 'package:beyondtheclass/pages/profile/settings/personalInfo/ProfileImageUploadPage.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:beyondtheclass/shared/widgets/my_dropdown.dart';
import 'package:beyondtheclass/shared/widgets/my_snackbar.dart';
import 'package:beyondtheclass/utils/authstateChanger.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PersonalInfoEditPage extends ConsumerStatefulWidget {
  const PersonalInfoEditPage({super.key});

  @override
  ConsumerState<PersonalInfoEditPage> createState() =>
      _PersonalInfoEditPageState();
}

class _PersonalInfoEditPageState extends ConsumerState<PersonalInfoEditPage> {
  bool isEditing = false;
  bool editPersonalEmail = false;
  bool _enableOtpField = false;
  bool _requireUniversityOtp = false;

  bool editSecondaryEmail = false;
  bool _enableSecondaryEmailOtpField = false;

  final apiClient = ApiClient();
  final nameController = TextEditingController();
  final universityEmailController = TextEditingController();
  final personalEmailController = TextEditingController();
  final secondaryPersonalEmailController = TextEditingController();
  final otpController = TextEditingController();
  final universityOtpController = TextEditingController();
  final graduationYearController = TextEditingController();
  String imageURl = '';
  DateTime? _selectedGraduationDate;

  String userDepartmentId = '';
  String userDepartmentName = '';

  List<Map<String, dynamic>> departmentsInCampus = [];
  String? selectedDepartment;

  late dynamic role;
  dynamic signedInEmail = '';
  bool showChangeDeptIcon  = false;


  @override
  void initState() {
    super.initState();
    getAllDepartments();
    final user = ref.read(authProvider).user;

    log("Auth Provider: $user");
    nameController.text = user?['name'];
    universityEmailController.text = user?['universityEmail'];
    personalEmailController.text = user?['personalEmail'];
    secondaryPersonalEmailController.text = user?['secondaryPersonalEmail'];
    imageURl = user?['profile']?['picture'];
    signedInEmail = user?['email']?.toString() ?? '';
    role = user?['role']?.toString() ?? '';
    if (user?['graduationYear'] != null) {
      graduationYearController.text = user?['graduationYear']?.toString() ?? '';
      _selectedGraduationDate = DateTime(user?['graduationYear'], 1, 1);
    }

    userDepartmentId = user?['university']?['departmentId']?['_id'];
    userDepartmentName = user?['university']?['departmentId']?['name'];
  }

  @override
  void dispose() {
    nameController.dispose();
    universityEmailController.dispose();
    personalEmailController.dispose();
    secondaryPersonalEmailController.dispose();
    otpController.dispose();
    universityOtpController.dispose();
    graduationYearController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileImageUploadPage(),
        ),
      );

      if (result == true) {
        // Refresh profile data if image was updated successfully
        showSnackbar(context, "Upload Successful");
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      showSnackbar(context, 'Error picking media: $e', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error picking media: $e'),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
    }
  }

  Future<void> updateName() async {
    try {
      await apiClient.put(
        '/api/user/update/name',
        {
          'name': nameController.text,
        },
      );
      setState(() {
        isEditing = false;
      });
      AuthStateChanger.updateAuthState(ref, nameController.text, 'name');
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: const Text('Name updated successfully'),
        //     backgroundColor: Theme.of(context).colorScheme.primary,
        //   ),
        // );
        showSnackbar(context, 'Name updated successfully');
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Error updating name: $e', isError: true);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Error updating name: $e'),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //   ),
        // );
      }
    }
  }

  Future<void> updateEmail({bool isPersonalEmail = true}) async {
    try {
      String val = isPersonalEmail ? 'personalEmail' : 'secondaryPersonalEmail';

      final response = await apiClient.put(
        '/api/user/update/$val',
        isPersonalEmail
            ? {'personalEmail': personalEmailController.text}
            : {'secondaryPersonalEmail': secondaryPersonalEmailController.text},
      );
      if (response.isNotEmpty) {
        setState(() {
          if (isPersonalEmail) {
            _enableOtpField = true;
            _requireUniversityOtp = response['requireUniversityOtp'] == true;
          } else {
            _enableSecondaryEmailOtpField = true;
          }
        });
      }
    } catch (e) {
      showSnackbar(context, 'Error updating personal email: $e', isError: true);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error updating personal email: $e'),
      //   ),
      // );
    } finally {
      if (isPersonalEmail) {
        setState(() {
          editPersonalEmail = false;
        });
      } else {
        setState(() {
          editSecondaryEmail = false;
        });
      }
    }
  }

  Future<void> verifyOtp({bool isPersonalEmail = true}) async {
    try {
      String val = isPersonalEmail ? 'personalEmail' : 'secondaryPersonalEmail';
      String emailString = isPersonalEmail
          ? personalEmailController.text
          : secondaryPersonalEmailController.text;
      Map<String, String> payload = {
        'otp': otpController.text,
        'email': emailString,
      };
      if (_requireUniversityOtp && isPersonalEmail) {
        payload['universityEmailOtp'] = universityOtpController.text;
      }
      final response = await apiClient.post(
        '/api/user/verify/$val/otp',
        payload,
      );
      if (response.isNotEmpty) {
        setState(() {
          if (isPersonalEmail) {
            _enableOtpField = false;
            _requireUniversityOtp = false;
            universityOtpController.clear();
          } else {
            _enableSecondaryEmailOtpField = false;
          }
          otpController.clear();
        });

        final userData = response['$val'];
        AuthStateChanger.updateAuthState(ref, emailString, val.toString());
      }
      if (mounted) {
        showSnackbar(context, "Email Successfully changed");
      }
    } catch (e) {
      showSnackbar(context, "Error Verifying OTP $e", isError: true);
    }
  }

  Future<void> _pickGraduationYear(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedGraduationDate ?? DateTime(now.year),
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      helpText: 'Select Graduation Year',
      fieldLabelText: 'Graduation Year',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.primary,
                    surface: Theme.of(context).colorScheme.surface,
                  )
                : ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary,
                    surface: Theme.of(context).colorScheme.surface,
                  ),
          ),
          child: child!,
        );
      },
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    if (picked != null) {
      setState(() {
        _selectedGraduationDate = picked;
        graduationYearController.text = picked.year.toString();
      });
    }
  }

  Future<void> updateDepartment() async {
    try {
      if (selectedDepartment == '' || selectedDepartment == userDepartmentId) {
        showSnackbar(
            context, "Department cannot be the same as before or empty");
        return;
      }

      final shouldContinue = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            title: const Text(
              "Update Department?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You can only change your department once.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "To change it again, contact:",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "ceo@beyondtheclass.me",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Go Ahead",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (shouldContinue != true) {
        return;
      }

      log("User chose to continue");

      final response = await apiClient.put('/api/user/department/change-once',
          {'departmentId': selectedDepartment});
      log("RESPONSE $response ${response['message'] == null}");

      if (response['access_token'] != null) {
        log("message here2");
        final token = response['access_token'];
        final dataJSON = JwtDecoder.decode(token);

        await ref.read(authProvider.notifier).updateAuthState(dataJSON, token);

        if (mounted) {
          showSnackbar(context, "Department Changed Successfully");
        }
      } else if (response['message'] != null) {
        log("message here3");
        setState(() {
          selectedDepartment = userDepartmentId;
        });
        if (mounted) {
          showSnackbar(context, response['message'].toString());
        }
      }
      showChangeDeptIcon  = false;
      setState(() {
        
selectedDepartment = userDepartmentId;
      });
      // Navigator.pop(context);
    } catch (e) {
      log("error updateDepartment $e");
      showSnackbar(context, e.toString(), isError: true);
    }
  }

  void getAllDepartments() async {
    try {
      final response = await apiClient.get('/api/department/campus/auth');
      log("DATA IN DEPARMTENTS $response");
      log("AGIN  ${response['departmentsInFormat']}");
      final List<Map<String, dynamic>> data =
          (response['departmentsInFormat'] as List)
              .whereType<Map<String, dynamic>>()
              .toList();

      departmentsInCampus = data;
      setState(() {
        // departmentsInCampus= (data)
        //       .map((uni) => {
        //             'name': uni['name'],
        //             '_id': uni['_id'],});
      });
    } catch (e) {
      log("Error in getallDepaartments $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final surfaceColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
// final shadowColor = isDark ? Colors.transparent : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Personal Info'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Container(
        // decoration: BoxDecoration(
        // color: surfaceColor,
        // borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: borderColor),
        //   boxShadow: [
        //     if (!isDark)
        //       BoxShadow(
        //         color: shadowColor,
        //         blurRadius: 4,
        //         offset: Offset(0, 2),
        //       ),
        //   ],
        // ),

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: borderColor,
                    backgroundImage:
                        imageURl != '' ? NetworkImage(imageURl) : null,
                    child: imageURl == ''
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: textColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _pickMedia,
                      icon: Icon(Icons.upload, color: textColor),
                      label: Text('Change Profile Picture',
                          style: TextStyle(color: textColor)),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              MyDropdownField<String>(
                value: userDepartmentId != ''
                    ? userDepartmentId
                    : selectedDepartment,
                items: departmentsInCampus,
                label: "Select Department",
                validator: dropdownValidator(selectedDepartment, 'Department'),
                onChanged: (value) {
                  log("VAlue $value");
                  if( selectedDepartment != userDepartmentId){
                    showChangeDeptIcon= true;
                  }
                  setState(() {
                    selectedDepartment = value;
                  });
                },
              ),

              if (showChangeDeptIcon && userDepartmentId != '' &&
                  userDepartmentId != selectedDepartment) ...[
                IconButton(onPressed: updateDepartment, icon: Icon(Icons.check))
              ],

              // Name Section
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        readOnly: !isEditing,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        isEditing
                            ? updateName()
                            : setState(() => isEditing = true);
                      },
                      icon: Icon(isEditing ? Icons.check : Icons.edit,
                          color: mutedTextColor),
                    ),
                  ],
                ),
              ),

              if (role == AppRoles.student) ...[
                Text('Graduation Year',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickGraduationYear(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: graduationYearController,
                      readOnly: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Select graduation year',
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        suffixIcon:
                            Icon(Icons.calendar_today, color: mutedTextColor),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],

              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: TextButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePassword(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Change Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: backgroundColor,
                          )),
                    )),
              ),
              // Name Section
              if (role != AppRoles.extOrg || role != AppRoles.noAccess) ...[
                Text(
                  'University Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.56),
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: universityEmailController,
                          readOnly: true,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your university email',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (role == AppRoles.student || role == AppRoles.alumni) ...[
                Text(
                  'Personal Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: personalEmailController,
                          readOnly: !editPersonalEmail,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your personal email',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (editPersonalEmail) {
                            updateEmail();
                          } else {
                            setState(() {
                              editPersonalEmail = true;
                            });
                          }
                        },
                        icon:
                            Icon(editPersonalEmail ? Icons.check : Icons.edit),
                      ),
                    ],
                  ),
                ),
                if (_enableOtpField) ...[
                  if (_requireUniversityOtp) ...[
                    Text('University Email OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: universityOtpController,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Enter OTP sent to your university email',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Personal Email OTP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: otpController,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter OTP sent to your personal email',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: verifyOtp,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Verify OTP(s)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )),
                ],
              ],

              if (role == AppRoles.alumni) ...[
                Text(
                  'Secondary Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: secondaryPersonalEmailController,
                          readOnly: !editSecondaryEmail,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your secondary email',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (editSecondaryEmail) {
                            updateEmail(isPersonalEmail: false);
                          } else {
                            setState(() {
                              editSecondaryEmail = true;
                            });
                          }
                        },
                        icon:
                            Icon(editSecondaryEmail ? Icons.check : Icons.edit),
                      ),
                    ],
                  ),
                ),
                if (_enableSecondaryEmailOtpField) ...[
                  Text('Personal Email OTP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: otpController,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter OTP sent to your personal email',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => verifyOtp(isPersonalEmail: false),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Verify OTP(s)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )),
                ],
              ],
            ],
          ),
        ),
      ),
    );
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
