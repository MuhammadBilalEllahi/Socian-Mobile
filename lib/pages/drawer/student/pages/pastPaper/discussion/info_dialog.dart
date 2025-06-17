import 'package:flutter/material.dart';
import 'package:socian/core/utils/constants.dart';

class InfoDialog extends StatelessWidget {
  final Map<String, dynamic> file;
  final Map<String, dynamic> paper;
  final int fileIndex;

  const InfoDialog({
    super.key,
    required this.file,
    required this.paper,
    required this.fileIndex,
  });

  Widget _buildInfoRow(
      String label, String value, Color foreground, Color mutedForeground) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Shadcn-style color scheme
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

    return Dialog(
      backgroundColor: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 32,
                    color: primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Past Paper Info',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: foreground,
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'File Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Text(
                  'File ${fileIndex + 1}',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PDF URL:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: SelectableText(
                  "${ApiConstants.baseUrl}/api/uploads/${file['url']}",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: foreground,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Information:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Uploaded by', file['uploadedBy']['name'],
                        foreground, mutedForeground),
                    _buildInfoRow('Username', file['uploadedBy']['username'],
                        foreground, mutedForeground),
                    _buildInfoRow(
                        'Email',
                        file['uploadedBy']['universityEmail'],
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Uploaded at',
                        DateTime.parse(file['uploadedAt'])
                            .toString()
                            .split('.')[0],
                        foreground,
                        mutedForeground),
                  ],
                ),
              ),
              if (file['teachers'] != null && file['teachers'].isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Associated Teachers:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 8),
                ...file['teachers']
                    .map<Widget>((teacher) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (teacher['imageUrl'] != null)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(teacher['imageUrl']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: primary,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          teacher['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: foreground,
                                          ),
                                        ),
                                        Text(
                                          teacher['email'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (teacher['rating'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${teacher['rating']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (teacher['department'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: muted,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Department: ${teacher['department']['name']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: mutedForeground,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (teacher['onLeave'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: teacher['onLeave']
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    teacher['onLeave'] ? 'On Leave' : 'Active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: teacher['onLeave']
                                          ? Colors.orange
                                          : Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (teacher['feedbackSummary'] != null &&
                                  teacher['feedbackSummary'].isNotEmpty) ...[
                                Text(
                                  'Recent Feedback:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: muted,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    teacher['feedbackSummary'][0]['summary'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: mutedForeground,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ))
                    .toList(),
              ],
              const SizedBox(height: 16),
              Text(
                'Paper Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Paper Name', paper['name'], foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Type', paper['type'], foreground, mutedForeground),
                    _buildInfoRow('Category', paper['category'], foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Term', paper['term'], foreground, mutedForeground),
                    _buildInfoRow(
                        'Academic Year',
                        paper['academicYear'].toString(),
                        foreground,
                        mutedForeground),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Metadata:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        'Views',
                        paper['metadata']['views'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Downloads',
                        paper['metadata']['downloads'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Answers',
                        paper['metadata']['answers'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Total Questions',
                        paper['metadata']['totalQuestions'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Answered Questions',
                        paper['metadata']['answeredQuestions'].toString(),
                        foreground,
                        mutedForeground),
                    _buildInfoRow(
                        'Last Accessed',
                        DateTime.parse(paper['metadata']['lastAccessed'])
                            .toString()
                            .split('.')[0],
                        foreground,
                        mutedForeground),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
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
    );
  }
}
