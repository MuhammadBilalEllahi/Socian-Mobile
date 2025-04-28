import 'package:flutter/material.dart';

class VerticalShimmerCard extends StatelessWidget {
  final Color cardBg;
  final Color border;

  const VerticalShimmerCard({
    super.key,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(top: 6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
