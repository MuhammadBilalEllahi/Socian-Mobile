import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:socian/shared/services/api_client.dart';

class UploadModal extends StatefulWidget {
  final String departmentId;
  final Future<Map<String, dynamic>> pastPapers;
  final VoidCallback onUploadSuccess;

  const UploadModal({
    super.key,
    required this.departmentId,
    required this.pastPapers,
    required this.onUploadSuccess,
  });

  @override
  State<UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<UploadModal> {
  final ApiClient apiClient = ApiClient();

  // Controllers for the upload form
  final TextEditingController _paperNameController = TextEditingController();
  String _selectedType = 'MIDTERM';
  String _selectedTerm = 'FALL';
  String _selectedTermMode = 'THEORY';
  String _selectedYear = DateTime.now().year.toString();
  String? _sessionType;
  String? _selectedSubject;
  String? _selectedTeacher;
  List<dynamic> _teachers = [];
  PlatformFile? _selectedFile;

  // Error states
  String? _paperNameError;
  String? _subjectError;
  String? _fileError;
  String? _teacherError;
  String? _typeError;
  String? _termError;
  String? _termModeError;
  String? _sessionTypeError;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  void _clearErrors() {
    setState(() {
      _paperNameError = null;
      _subjectError = null;
      _fileError = null;
      _teacherError = null;
      _typeError = null;
      _termError = null;
      _termModeError = null;
      _sessionTypeError = null;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      // Clear previous errors
      _clearErrors();

      // Validate paper name
      if (_paperNameController.text.trim().isEmpty) {
        _paperNameError = 'Paper name is required';
        isValid = false;
      }

      // Validate subject
      if (_selectedSubject == null) {
        _subjectError = 'Please select a subject';
        isValid = false;
      }

      // Validate file
      if (_selectedFile == null) {
        _fileError = 'Please select a PDF file';
        isValid = false;
      }

      // Validate type
      if (_selectedType.isEmpty) {
        _typeError = 'Please select a type';
        isValid = false;
      }

      // Validate term for MIDTERM and FINAL
      if ((_selectedType == 'MIDTERM' || _selectedType == 'FINAL') &&
          _selectedTerm.isEmpty) {
        _termError = 'Please select a term';
        isValid = false;
      }

      // Validate term mode for MIDTERM and FINAL
      if ((_selectedType == 'MIDTERM' || _selectedType == 'FINAL') &&
          _selectedTermMode.isEmpty) {
        _termModeError = 'Please select a term mode';
        isValid = false;
      }

      // Validate session type for SESSIONAL
      if (_selectedType == 'SESSIONAL' && _sessionType == null) {
        _sessionTypeError = 'Please select a session type';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _fetchTeachers() async {
    try {
      final response = await apiClient.get('/api/teacher/all');
      setState(() {
        _teachers = response['data'] as List<dynamic>;
      });
    } catch (e) {
      // debugPrint('Error fetching teachers: $e');
    }
  }

  @override
  void dispose() {
    _paperNameController.dispose();
    super.dispose();
  }

  List<dynamic> _filterSubjects(List<dynamic> subjects) {
    return subjects;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        onFileLoading: (FilePickerStatus status) {
          // debugPrint("FilePickerStatus: $status");
        },
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      // debugPrint('Error picking file: $e');
    }
  }

  Future<void> _uploadPastPaper() async {
    if (!_validateForm() || !_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final formData = {
        'file': MultipartFile.fromBytes(
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ),
        'year': _selectedYear,
        'type': _selectedType,
        'term': _selectedTerm,
        'termMode': _selectedTermMode,
        'paperName': _paperNameController.text,
        'teachers': _selectedTeacher != null ? [_selectedTeacher] : [],
        'subjectId': _selectedSubject,
        'departmentId': widget.departmentId,
        if (_selectedType == 'SESSIONAL') 'sessionType': _sessionType,
      };

      log("FORM DATA: $formData and isLoading: $isLoading");

      await apiClient.postFormData('/api/pastpaper/upload', formData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Past paper uploaded successfully')),
      );

      widget.onUploadSuccess();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading past paper: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    final primary =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFF18181B);
    final destructive =
        isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFEF4444);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mutedForeground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Past Paper',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: foreground,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: mutedForeground),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _paperNameController,
                      style: TextStyle(color: foreground),
                      decoration: InputDecoration(
                        labelText: 'Paper Name',
                        labelStyle: TextStyle(color: mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: destructive),
                        ),
                        filled: true,
                        fillColor: accent,
                        errorText: _paperNameError,
                        errorStyle: TextStyle(color: destructive),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: widget.pastPapers,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final subjects =
                              snapshot.data!['subjects'] as List<dynamic>;
                          return DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            dropdownColor: background,
                            style: TextStyle(color: foreground),
                            decoration: InputDecoration(
                              labelText: 'Subject',
                              labelStyle: TextStyle(color: mutedForeground),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primary),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: destructive),
                              ),
                              filled: true,
                              fillColor: accent,
                              errorText: _subjectError,
                              errorStyle: TextStyle(color: destructive),
                            ),
                            items: subjects
                                .map<DropdownMenuItem<String>>((subject) {
                              return DropdownMenuItem<String>(
                                value: subject['_id'] as String,
                                child: Text(
                                  subject['name'] as String,
                                  style: TextStyle(color: foreground),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value;
                                _subjectError = null;
                              });
                            },
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTeacher,
                      dropdownColor: background,
                      style: TextStyle(color: foreground),
                      decoration: InputDecoration(
                        labelText: 'Teacher',
                        labelStyle: TextStyle(color: mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: destructive),
                        ),
                        filled: true,
                        fillColor: accent,
                        errorText: _teacherError,
                        errorStyle: TextStyle(color: destructive),
                      ),
                      items: _teachers.map<DropdownMenuItem<String>>((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher['_id'] as String,
                          child: Text(
                            teacher['name'] as String,
                            style: TextStyle(color: foreground),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTeacher = value;
                          _teacherError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: background,
                      style: TextStyle(color: foreground),
                      decoration: InputDecoration(
                        labelText: 'Type',
                        labelStyle: TextStyle(color: mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: destructive),
                        ),
                        filled: true,
                        fillColor: accent,
                        errorText: _typeError,
                        errorStyle: TextStyle(color: destructive),
                      ),
                      items: [
                        'MIDTERM',
                        'FINAL',
                        'SESSIONAL',
                        'ASSIGNMENT',
                        'QUIZ'
                      ]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type,
                                    style: TextStyle(color: foreground)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          _typeError = null;
                          if (value != 'SESSIONAL') {
                            _sessionType = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedType == 'MIDTERM' ||
                        _selectedType == 'FINAL') ...[
                      DropdownButtonFormField<String>(
                        value: _selectedTerm,
                        dropdownColor: background,
                        style: TextStyle(color: foreground),
                        decoration: InputDecoration(
                          labelText: 'Term',
                          labelStyle: TextStyle(color: mutedForeground),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: destructive),
                          ),
                          filled: true,
                          fillColor: accent,
                          errorText: _termError,
                          errorStyle: TextStyle(color: destructive),
                        ),
                        items: ['FALL', 'SPRING', 'SUMMER']
                            .map((term) => DropdownMenuItem(
                                  value: term,
                                  child: Text(term,
                                      style: TextStyle(color: foreground)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTerm = value!;
                            _termError = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTermMode,
                        dropdownColor: background,
                        style: TextStyle(color: foreground),
                        decoration: InputDecoration(
                          labelText: 'Term Mode',
                          labelStyle: TextStyle(color: mutedForeground),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: destructive),
                          ),
                          filled: true,
                          fillColor: accent,
                          errorText: _termModeError,
                          errorStyle: TextStyle(color: destructive),
                        ),
                        items: ['THEORY', 'PRACTICAL']
                            .map((mode) => DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode,
                                      style: TextStyle(color: foreground)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTermMode = value!;
                            _termModeError = null;
                          });
                        },
                      ),
                    ],
                    if (_selectedType == 'SESSIONAL') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _sessionType,
                        dropdownColor: background,
                        style: TextStyle(color: foreground),
                        decoration: InputDecoration(
                          labelText: 'Session Type',
                          labelStyle: TextStyle(color: mutedForeground),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primary),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: destructive),
                          ),
                          filled: true,
                          fillColor: accent,
                          errorText: _sessionTypeError,
                          errorStyle: TextStyle(color: destructive),
                        ),
                        items: ['1', '2']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type,
                                      style: TextStyle(color: foreground)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _sessionType = value;
                            _sessionTypeError = null;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedYear,
                      dropdownColor: background,
                      style: TextStyle(color: foreground),
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: TextStyle(color: mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: primary),
                        ),
                        filled: true,
                        fillColor: accent,
                      ),
                      items: List.generate(
                        DateTime.now().year - 1999 + 1,
                        (index) => DropdownMenuItem(
                          value: (DateTime.now().year - index).toString(),
                          child: Text(
                            (DateTime.now().year - index).toString(),
                            style: TextStyle(color: foreground),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _selectedYear = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: border),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await _pickFile();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.upload_file,
                                        color: mutedForeground),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedFile?.name ??
                                            'Select PDF File',
                                        style: TextStyle(
                                          color: _selectedFile != null
                                              ? foreground
                                              : mutedForeground,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_fileError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _fileError!,
                              style: TextStyle(
                                color: destructive,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _uploadPastPaper,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
