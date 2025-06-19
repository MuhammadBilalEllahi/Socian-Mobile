import 'package:flutter/material.dart';
import 'package:socian/pages/explore/SocietyProvider.dart';
import 'package:socian/pages/explore/components/shimmer/vertical_shimmer_list.dart';
import 'package:socian/pages/explore/society.model.dart';

import 'vertical_society_card.dart';

class VerticalSocietiesList extends StatelessWidget {
  final SocietiesState state;
  final List<Society> Function(List<Society>)? filterFn;
  final Color fg;
  final Color cardBg;
  final Color border;
  final Color muted;
  final Color joinedBg;
  final Color joinedFg;
  final VoidCallback? onCardTap;

  const VerticalSocietiesList({
    super.key,
    required this.state,
    required this.fg,
    required this.cardBg,
    required this.border,
    required this.muted,
    required this.joinedBg,
    required this.joinedFg,
    this.filterFn,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingSearch) {
      return VerticalShimmerList(cardBg: cardBg, border: border);
    }
    List<Society> filteredSubscribed = filterFn != null
        ? filterFn!(state.subscribedSocieties)
        : state.subscribedSocieties;
    List<Society> filteredPublic = filterFn != null
        ? filterFn!(state.publicSocieties)
        : state.publicSocieties;
    List<Society> filteredOther = filterFn != null
        ? filterFn!(state.otherSocieties)
        : state.otherSocieties;
    final totalCount = filteredSubscribed.length +
        filteredPublic.length +
        filteredOther.length;
    if (totalCount == 0) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "No societies found.",
          style: TextStyle(fontSize: 16, color: muted),
        ),
      );
    }
    List<Widget> children = [];
    if (filteredSubscribed.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4),
        child: Text(
          "Joined Societies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: -0.5,
          ),
        ),
      ));
      children.addAll(filteredSubscribed.map((society) => VerticalSocietyCard(
            society: society,
            isJoined: true,
            fg: fg,
            cardBg: cardBg,
            border: border,
            muted: muted,
            joinedBg: joinedBg,
            joinedFg: joinedFg,
            onCardTap: onCardTap,
          )));
    }
    if (filteredPublic.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 12, top: 16, bottom: 4),
        child: Text(
          "Public Societies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: -0.5,
          ),
        ),
      ));
      children.addAll(filteredPublic.map((society) => VerticalSocietyCard(
            society: society,
            isJoined: false,
            fg: fg,
            cardBg: cardBg,
            border: border,
            muted: muted,
            joinedBg: joinedBg,
            joinedFg: joinedFg,
            onCardTap: onCardTap,
          )));
    }
    if (filteredOther.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 12, top: 16, bottom: 4),
        child: Text(
          "Other Societies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: -0.5,
          ),
        ),
      ));
      children.addAll(filteredOther.map((society) => VerticalSocietyCard(
            society: society,
            isJoined: false,
            fg: fg,
            cardBg: cardBg,
            border: border,
            muted: muted,
            joinedBg: joinedBg,
            joinedFg: joinedFg,
            onCardTap: onCardTap,
          )));
    }
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
