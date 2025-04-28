import 'package:beyondtheclass/pages/explore/society.model.dart';
import 'package:flutter/material.dart';

class VerticalSocietyCard extends StatelessWidget {
  final Society society;
  final bool isJoined;
  final Color fg;
  final Color cardBg;
  final Color border;
  final Color muted;
  final Color joinedBg;
  final Color joinedFg;

  const VerticalSocietyCard({
    super.key,
    required this.society,
    required this.isJoined,
    required this.fg,
    required this.cardBg,
    required this.border,
    required this.muted,
    required this.joinedBg,
    required this.joinedFg,
  });

  @override
  Widget build(BuildContext context) {
    List<String> fields = [];
    if (society.university != null) fields.add('university');
    if (society.campus != null) fields.add('campus');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (society.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  society.image!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: border,
                    child: Icon(Icons.broken_image, size: 30, color: muted),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group, size: 30, color: muted),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            society.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: fg,
                              overflow: TextOverflow.ellipsis,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        if (isJoined)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: joinedBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border, width: 1),
                            ),
                            child: Text(
                              'Joined',
                              style: TextStyle(
                                color: joinedFg,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (fields.contains('university'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'University: ${society.university ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (fields.contains('campus'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Campus: ${society.campus ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (society.category != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Category: ${society.category}',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (society.membersCount != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Members: ${society.membersCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (society.allows != null && society.allows!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Allows: ${society.allows!.map((e) => e[0].toUpperCase() + e.substring(1)).join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      society.description ?? 'No Description',
                      style: TextStyle(
                        fontSize: 13,
                        color: fg.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
