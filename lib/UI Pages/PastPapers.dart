
import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class PastPapers extends StatefulWidget {
  const PastPapers({super.key});

  @override
  _PastPapersState createState() => _PastPapersState();
}

class _PastPapersState extends State<PastPapers> {
  late Future<Map<String, dynamic>> pastPapers = Future.value({});
  final ApiClient apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    fetchPastPapers();
  }

  void fetchPastPapers() async {
    final response = await apiClient.get(ApiConstants.subjectPastpapers);
    setState(() {
      pastPapers = Future.value(response);
    });
  }

  Future<void> _launchPDF(String pdfUrl) async {
    try {
      final downloadUrl = "${ApiConstants.pdfBaseURl}$pdfUrl";
      final Uri url = Uri.parse(downloadUrl);
      if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $downloadUrl')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Papers',
            style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.deepPurple[50],
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: pastPapers,
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
                    'Error Loading Past Papers',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${snapshot.error}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.list, color: Colors.grey, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'No Past Papers Available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else {
            final papers = snapshot.data!['pastPapers']!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final paper = papers[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text(
                      'Academic Year ${paper['year']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    children: [
                      _buildSectionTitle('Assignments'),
                      _buildAssignmentSection(paper['assignments']),
                      const Divider(),
                      _buildSectionTitle('Fall Final Theory Papers'),
                      _buildPaperSection(paper['fall']['final']['theory']),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple[700],
        ),
      ),
    );
  }

  Widget _buildAssignmentSection(List assignments) {
    if (assignments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('No assignments available',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: assignments.map((assignment) {
        return ListTile(
          leading: const Icon(Icons.assignment, color: Colors.deepPurple),
          title: Text(assignment['name']),
          trailing: IconButton(
            icon: const Icon(Icons.download, color: Colors.deepPurple),
            onPressed: () => _launchPDF(assignment['file']['pdf']),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaperSection(List papers) {
    if (papers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('No theory papers available',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: papers.map((paper) {
        return ListTile(
          leading: const Icon(Icons.description, color: Colors.deepPurple),
          title: Text(paper['name']),
          trailing: IconButton(
            icon: const Icon(Icons.download, color: Colors.deepPurple),
            onPressed: () => _launchPDF(paper['file']['pdf']),
          ),
        );
      }).toList(),
    );
  }
}
