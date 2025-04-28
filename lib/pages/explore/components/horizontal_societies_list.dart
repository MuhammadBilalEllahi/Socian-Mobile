import 'package:beyondtheclass/pages/explore/components/shimmer_list.dart';
import 'package:flutter/material.dart';
import '../society.model.dart';
import 'society_card.dart';

class HorizontalSocietiesList extends StatelessWidget {
  final List<Society> societies;
  final List<String> fields;
  final bool isLoading;
  final Color fg;
  final Color cardBg;
  final Color border;
  final Color muted;
  final Color chipBg;
  final Color chipFg;

  final List<Society> Function(List<Society>)? filterFn;

  const HorizontalSocietiesList({
    super.key,
    required this.societies,
    required this.fields,
    required this.isLoading,
    required this.fg,
    required this.cardBg,
    required this.border,
    required this.muted,
    required this.chipBg,
    required this.chipFg,
    this.filterFn,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShimmerList(cardBg: cardBg, border: border);
    }
    final filtered = filterFn != null ? filterFn!(societies) : societies;
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "No societies found.",
          style: TextStyle(fontSize: 16, color: muted),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int index) {
          final society = filtered[index];
          return SocietyCard(
            society: society,
            fields: fields,
            fg: fg,
            cardBg: cardBg,
            border: border,
            muted: muted,
            chipBg: chipBg,
            chipFg: chipFg,
          );
        },
      ),
    );
  }
}
