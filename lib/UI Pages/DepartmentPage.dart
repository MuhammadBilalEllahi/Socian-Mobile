import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/UI pages/PastPapers.dart'; // Import the PastPapers page.

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  late Future<List<dynamic>> departments = Future.value([]);
  final ApiClient apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  void fetchDepartments() async {
    try {
      final response = await apiClient.get(ApiConstants.campus);
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

    Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => PastPapers(id: '67818286a465ca0130eafafd'),
        // builder: (context) => PastPapers(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            'Departments',
            style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: departments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Departments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${snapshot.error}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }

          // else if (!snapshot.hasData || snapshot.data!.isEmpty)
          else if (snapshot.data?.isEmpty ?? true)

          {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.list, color: Colors.grey, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'No Departments Available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else {
            final departmentList = snapshot.data!;
            print("departmentList is");
            print(departmentList);
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: departmentList.length,
              itemBuilder: (context, index) {
                final department = departmentList[index];
                print("department is");
                print(department);
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade900, Colors.tealAccent.shade400
                        ],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(

                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          department['name']?.isNotEmpty == true ? department['name'][0] : '?',
                          style: const TextStyle(color: Colors.teal),
                        ),
                      ),

                      title: Text(
                        department['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        final departmentId = department['_id']?.toString();
                        if (departmentId == null || departmentId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid Department ID')),
                          );
                          return;
                        }
                        navigateToPastPapers(departmentId);
                      },

                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
