import 'package:flutter/material.dart';
import 'package:socian/pages/explore/page/SocietyPage.dart';

import '../society.model.dart';

class SocietyCard extends StatelessWidget {
  final Society society;
  final List<String> fields;
  final Color fg;
  final Color cardBg;
  final Color border;
  final Color muted;
  final Color chipBg;
  final Color chipFg;

  const SocietyCard({
    super.key,
    required this.society,
    required this.fields,
    required this.fg,
    required this.cardBg,
    required this.border,
    required this.muted,
    required this.chipBg,
    required this.chipFg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SocietyPage(societyId: society.id)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        width: MediaQuery.of(context).size.width * 0.7,
        height: 72,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Smaller Avatar
              if (society.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    society.image!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 36,
                      height: 36,
                      color: border,
                      child: Icon(Icons.broken_image, size: 18, color: muted),
                    ),
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.group, size: 18, color: muted),
                ),
              const SizedBox(width: 10),
              // Main info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            society.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: fg,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (society.category != null)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              society.category!,
                              style: TextStyle(
                                fontSize: 10,
                                color: chipFg,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Show one key detail: university, campus, or members
                    Row(
                      children: [
                        if (fields.contains('university') &&
                            society.university != null)
                          Row(
                            children: [
                              Icon(Icons.school, size: 12, color: muted),
                              const SizedBox(width: 3),
                              Text(
                                society.university!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: muted,
                                    fontWeight: FontWeight.w400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        else if (fields.contains('campus') &&
                            society.campus != null)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: muted),
                              const SizedBox(width: 3),
                              Text(
                                society.campus!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: muted,
                                    fontWeight: FontWeight.w400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        else if (society.membersCount != null)
                          Row(
                            children: [
                              Icon(Icons.people, size: 12, color: muted),
                              const SizedBox(width: 3),
                              Text(
                                '${society.membersCount}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: muted,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Optionally, a trailing arrow or badge
              Icon(Icons.chevron_right, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
