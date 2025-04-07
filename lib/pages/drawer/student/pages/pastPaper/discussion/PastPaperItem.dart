import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';

class PastPaperItem extends StatelessWidget {
  final Map<String, dynamic> paper;
  final Function(String url, String name, String year) onPaperSelected;
  final bool isFirst;
  final bool isLast;

  const PastPaperItem({
    super.key,
    required this.paper,
    required this.onPaperSelected,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2D2D2D),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (paper['file'] != null && paper['file']['url'] != null) {
            final url = "${ApiConstants.baseUrl}/api/uploads/${paper['file']['url']}";
            onPaperSelected(
              url,
              paper['name'],
              paper['academicYear']?.toString() ?? '',
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    paper['name']?.isNotEmpty == true ? paper['name'][0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paper['name'] ?? 'Untitled',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Year: ${paper['academicYear'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Type: ${paper['type'] ?? 'Unknown'}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.swipe,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}