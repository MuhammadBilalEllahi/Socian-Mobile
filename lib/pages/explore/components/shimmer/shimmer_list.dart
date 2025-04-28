import 'package:flutter/material.dart';
import 'shimmer_card.dart';

class ShimmerList extends StatelessWidget {
  final int count;
  final Color cardBg;
  final Color border;

  const ShimmerList({
    super.key,
    this.count = 3,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: count,
        itemBuilder: (context, index) =>
            ShimmerCard(cardBg: cardBg, border: border),
      ),
    );
  }
}
