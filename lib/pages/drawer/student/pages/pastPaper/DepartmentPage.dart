import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

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
      debugPrint("DEPARTMENTS? $response");
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
    Navigator.pushNamed(
      context,
      AppRoutes.subjectsInDepartmentScreen,
      arguments: {'_id': id}
    );
  }

  List<dynamic> _filterDepartments(List<dynamic> departments) {
    if (_searchQuery.isEmpty) return departments;
    return departments.where((department) =>
      department['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 15, 15), // Dark background
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Departments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 104, 104, 104), // Slightly lighter dark
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search departments...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color.fromARGB(255, 41, 41, 41),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 46, 46, 46)), // Purple
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Departments',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${snapshot.error}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
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
                        const Icon(Icons.list, color: Color(0xFF6B7280), size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'No Departments Available',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final filteredDepartments = _filterDepartments(snapshot.data!);
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDepartments.length,
                    itemBuilder: (context, index) {
                      final department = filteredDepartments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 41, 41, 41),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 182, 182, 182).withValues(alpha:0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              debugPrint("DEPARTMENT DATA $department");
                              final departmentId = department['_id']?.toString();
                              if (departmentId == null || departmentId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid Department ID'),
                                    backgroundColor: Color(0xFFEF4444),
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
                                      color: const Color.fromARGB(255, 165, 165, 165).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        department['name']?.isNotEmpty == true ? department['name'][0] : '?',
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
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
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 241, 241, 241),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color.fromARGB(255, 172, 172, 172),
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
