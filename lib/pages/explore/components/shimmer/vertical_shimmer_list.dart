import 'package:flutter/material.dart';
import 'vertical_shimmer_card.dart';

class VerticalShimmerList extends StatelessWidget {
  final int count;
  final Color cardBg;
  final Color border;

  const VerticalShimmerList({
    super.key,
    this.count = 6,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) =>
          VerticalShimmerCard(cardBg: cardBg, border: border),
    );
  }
}
