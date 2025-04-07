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
  late String id;
  String subjectName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (routeArgs?.containsKey('_id') ?? false) {
      id = routeArgs!['_id'];
      fetchPastPapers(id);
    } else {
      setState(() {
        pastPapers = Future.error('Invalid route arguments or missing ID');
      });
    }
  }

  void fetchPastPapers(String id) async {
    final String endpoint = "${ApiConstants.subjectPastpapers}/$id";
    try {
      final response = await apiClient.get(endpoint);
      debugPrint("PAST PAPERS? $response");
      setState(() {
        subjectName = response?['subjectName'] ?? '';
        pastPapers = Future.value(response ?? {});
      });
    } catch (e) {
      setState(() {
        pastPapers = Future.error('Failed to load past papers: $e');
      });
    }
  }

  Future<void> _launchPDF(String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PDF link available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final downloadUrl = "${ApiConstants.pdfBaseURl}$pdfUrl";
      final Uri url = Uri.parse(downloadUrl);
      if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $downloadUrl'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          subjectName.isEmpty ? 'Past Papers' : '$subjectName Past Papers',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: pastPapers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, color: Colors.grey[800], size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'No Past Papers Available',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final papers = snapshot.data!['papers'] as List;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final paper = papers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF27272A), width: 1),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        'Academic Year ${paper['academicYear']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      children: [
                        if (paper['papers'] != null) ...[
                          _buildSectionTitle('Papers'),
                          _buildPaperSection(paper['papers'] as List),
                        ],
                      ],
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPaperSection(List papers) {
    if (papers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No papers available',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: papers.map((paper) {
        String paperTitle = '${paper['type']}';
        if (paper['category'] != null) {
          paperTitle += ' (${paper['category']})';
        }
        if (paper['term'] != null) {
          paperTitle += ' - ${paper['term']}';
        }
        if (paper['sessionType'] != null) {
          paperTitle += ' - Session ${paper['sessionType']}';
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF09090B),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF27272A), width: 1),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.description, color: Colors.white, size: 20),
            ),
            title: Text(
              paperTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (paper['teachers'] != null && paper['teachers'].isNotEmpty)
                  Text(
                    'Teacher: ${paper['teachers'][0]['name']}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                if (paper['metadata'] != null)
                  Text(
                    'Views: ${paper['metadata']['views']} | Downloads: ${paper['metadata']['downloads']}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            onTap: () => _launchPDF(paper['pdfUrl']),
          ),
        );
      }).toList(),
    );
  }
}
