import 'package:flutter/material.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/shared/services/api_client.dart';

import 'upload_modal.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
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
      // debugPrint("SUBJECTS? $response");
      setState(() {
        pastPapers = Future.value(response);
      });
    } catch (e) {
      // debugPrint(e);
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

  void _showUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UploadModal(
        departmentId: id,
        pastPapers: pastPapers,
        onUploadSuccess: () {
          // Optionally refresh the subjects list after upload
          fetchSubjects(id);
        },
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
        body: Column(children: [
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
        ]));
  }
}
