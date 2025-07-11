import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/services/api_client.dart';

class Report extends ConsumerStatefulWidget {
  final String modelId;
  final String modelType; // 'post', 'society', 'comment', 'reply'

  const Report({
    super.key,
    required this.modelId,
    required this.modelType,
  });

  @override
  ConsumerState<Report> createState() => _ReportState();
}

class _ReportState extends ConsumerState<Report> {
  final apiClient = ApiClient();
  String? selectedReportType;
  bool isSubmitting = false;

  final List<Map<String, String>> reportTypes = [
    {
      'id': 'harassment',
      'name': 'Harassment',
      'description':
          'Bullying, threats, or abusive behavior towards individuals or groups'
    },
    {
      'id': 'spam',
      'name': 'Spam',
      'description':
          'Unwanted commercial content, repetitive posts, or misleading information'
    },
    {
      'id': 'inappropriate',
      'name': 'Inappropriate Content',
      'description':
          'Content that violates community guidelines or contains offensive material'
    },
    {
      'id': 'fake_news',
      'name': 'Fake News',
      'description': 'False or misleading information that could harm others'
    },
    {
      'id': 'violence',
      'name': 'Violence or Threats',
      'description':
          'Content promoting violence, self-harm, or threatening behavior'
    },
  ];

  Future<void> submitReport() async {
    if (selectedReportType == null) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      await apiClient.post('/api/report/submit', {
        'modelId': widget.modelId,
        'modelType': widget.modelType,
        'reportType': selectedReportType,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportSubmittedPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Content'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s wrong with this ${widget.modelType}?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the reason for reporting this ${widget.modelType}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: reportTypes.length,
                itemBuilder: (context, index) {
                  final reportType = reportTypes[index];
                  final isSelected = selectedReportType == reportType['id'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 1,
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedReportType = reportType['id'];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: reportType['id']!,
                              groupValue: selectedReportType,
                              onChanged: (value) {
                                setState(() {
                                  selectedReportType = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reportType['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reportType['description']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedReportType != null && !isSubmitting
                    ? submitReport
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
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
                        'Submit Report',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportSubmittedPage extends StatelessWidget {
  const ReportSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Submitted'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Report Submitted',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for helping us keep the community safe. We\'ll review your report and take appropriate action.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
