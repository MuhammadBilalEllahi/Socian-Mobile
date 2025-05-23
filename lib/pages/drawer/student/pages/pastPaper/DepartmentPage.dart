import 'package:flutter/material.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/shared/services/api_client.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  late Future<List<dynamic>> departments = Future.value([]);
  final ApiClient apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchDepartments() async {
    try {
      final response = await apiClient.get(ApiConstants.campus);
      // debugPrint("DEPARTMENTS? $response");
      setState(() {
        departments = Future.value(response['departments'] ?? []);
      });
    } catch (e) {
      setState(() {
        departments = Future.error('Failed to load departments: $e');
      });
    }
  }

  void navigateToPastPapers(String id) {
    Navigator.pushNamed(context, AppRoutes.subjectsInDepartmentScreen,
        arguments: {'_id': id});
  }

  List<dynamic> _filterDepartments(List<dynamic> departments) {
    if (_searchQuery.isEmpty) return departments;
    return departments
        .where((department) => department['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  final TextEditingController _fileNameController = TextEditingController();

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
          'Departments',
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: muted,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: foreground),
              decoration: InputDecoration(
                hintText: 'Search departments...',
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
            child: FutureBuilder<List<dynamic>>(
              future: departments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[400], size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Departments',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.data?.isEmpty ?? true) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list, color: mutedForeground, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'No Departments Available',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final filteredDepartments =
                      _filterDepartments(snapshot.data!);
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDepartments.length,
                    itemBuilder: (context, index) {
                      final department = filteredDepartments[index];
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // debugPrint("DEPARTMENT DATA $department");
                              final departmentId =
                                  department['_id']?.toString();
                              if (departmentId == null ||
                                  departmentId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid Department ID'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              navigateToPastPapers(departmentId);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: muted,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        department['name']?.isNotEmpty == true
                                            ? department['name'][0]
                                            : '?',
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      department['name'],
                                      style: TextStyle(
                                        color: foreground,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: mutedForeground,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
