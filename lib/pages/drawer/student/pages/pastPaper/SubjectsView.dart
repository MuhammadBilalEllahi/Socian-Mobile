import 'dart:developer';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SubjectsView extends StatefulWidget {
  const SubjectsView({super.key});

  @override
  State<SubjectsView> createState() => _SubjectsViewState();
}

class _SubjectsViewState extends State<SubjectsView> {
  late Future<Map<String, dynamic>> pastPapers = Future.value({});
  final ApiClient apiClient = ApiClient();
  late String id;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      print('Error fetching teachers: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _paperNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (routeArgs?.containsKey('_id') ?? false) {
      id = routeArgs!['_id'];
      fetchSubjects(id);
    } else {
      setState(() {
        pastPapers = Future.error('Invalid route arguments or missing ID');
      });
    }
  }

  Future<void> fetchSubjects(String id) async {
    try {
      final response =
          await apiClient.get('/api/department/subjects?departmentId=$id');
      debugPrint("SUBJECTS? $response");
      setState(() {
        pastPapers = Future.value(response);
      });
    } catch (e) {
      print(e);
    }
  }

  List<dynamic> _filterSubjects(List<dynamic> subjects) {
    if (_searchQuery.isEmpty) return subjects;
    return subjects
        .where((subject) => subject['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        onFileLoading: (FilePickerStatus status) {
          print("FilePickerStatus: $status");
        },
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _uploadPastPaper() async {
    if (!_validateForm()) {
      return;
    }

    try {
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
        'departmentId': id,
        if (_selectedType == 'SESSIONAL') 'sessionType': _sessionType,
      };

      log("FORM DATA: $formData");

      await apiClient.postFormData('/api/pastpaper/upload', formData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Past paper uploaded successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading past paper: $e')),
      );
    }
  }

  void _showUploadModal() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: border),
          ),
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
                        future: pastPapers,
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
                        items:
                            _teachers.map<DropdownMenuItem<String>>((teacher) {
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
                                onTap: _pickFile,
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
                          onPressed: _uploadPastPaper,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

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

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Subjects',
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: muted,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: _showUploadModal,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(Icons.publish_sharp, color: foreground),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: foreground),
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                hintStyle: TextStyle(color: mutedForeground),
                prefixIcon: Icon(Icons.search, color: mutedForeground),
                filled: true,
                fillColor: accent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: pastPapers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: foreground),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final subjects = snapshot.data!['subjects'] as List<dynamic>;
                  final filteredSubjects = _filterSubjects(subjects);

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            subject['name'],
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: mutedForeground,
                            size: 16,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.pastPaperScreen,
                                arguments: {'_id': subject['_id']});
                          },
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: Text(
                    'No subjects found',
                    style: TextStyle(color: foreground),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
