import 'package:flutter/material.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      width: MediaQuery.of(context).size.width * 0.85,
      height: 140,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            if (society.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  society.image!,
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 45,
                    height: 45,
                    color: border,
                    child: Icon(Icons.broken_image, size: 32, color: muted),
                  ),
                ),
              )
            else
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.group, size: 32, color: muted),
              ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and badge row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          society.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
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
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            society.category!,
                            style: TextStyle(
                              fontSize: 11,
                              color: chipFg,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // University & Campus
                  Row(
                    children: [
                      if (fields.contains('university') &&
                          society.university != null)
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 13, color: muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  society.university!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: muted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (fields.contains('campus') && society.campus != null)
                        Flexible(
                          child: Row(
                            children: [
                              if (fields.contains('university') &&
                                  society.university != null)
                                const SizedBox(width: 10),
                              Icon(Icons.location_on, size: 13, color: muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  society.campus!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: muted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (fields.contains('campus-self') &&
                          society.campus != null)
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.home, size: 13, color: muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  society.campus!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: muted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  // Members & Allows
                  Row(
                    children: [
                      if (society.membersCount != null)
                        Row(
                          children: [
                            Icon(Icons.people, size: 13, color: muted),
                            const SizedBox(width: 3),
                            Text(
                              '${society.membersCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: muted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      if (society.allows != null && society.allows!.isNotEmpty)
                        Row(
                          children: [
                            if (society.membersCount != null)
                              const SizedBox(width: 10),
                            Icon(Icons.lock_open, size: 13, color: muted),
                            const SizedBox(width: 3),
                            Text(
                              society.allows!
                                  .map((e) =>
                                      e[0].toUpperCase() + e.substring(1))
                                  .join(", "),
                              style: TextStyle(
                                fontSize: 12,
                                color: muted,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                  // const SizedBox(height: 6),
                  // Description
                  // Expanded(
                  //   child: Text(
                  //     society.description?.trim().isNotEmpty == true
                  //         ? society.description!
                  //         : 'No Description',
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       color: fg.withOpacity(0.85),
                  //       fontWeight: FontWeight.w400,
                  //       height: 1.3,
                  //     ),
                  //     maxLines: 2,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
