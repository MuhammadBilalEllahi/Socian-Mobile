import 'dart:async';
import 'package:beyondtheclass/components/rive/RepeatingThumbAnimation.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';

class PastPaperInfoCard extends StatefulWidget {
  final Map<String, dynamic> paper;
  final Function(String url, String name, String year) onPaperSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onChatBoxToggle;

  PastPaperInfoCard({
    super.key,
    required this.paper,
    required this.onPaperSelected,
    required this.onChatBoxToggle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<PastPaperInfoCard> createState() => _PastPaperInfoCardState();
}

class _PastPaperInfoCardState extends State<PastPaperInfoCard> {
  bool showDiscussionCard = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startToggleTimer();
  }

  void _startToggleTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted) {
        setState(() {
          showDiscussionCard = !showDiscussionCard;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      canRequestFocus: true,
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        widget.onChatBoxToggle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 750),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _buildCard(key: ValueKey(showDiscussionCard)),
      ),
    );
  }

  Widget _buildCard({required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF121212),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            if (!widget.isFirst)
              const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: Color.fromARGB(255, 206, 205, 205)),
            if (!widget.isFirst) const SizedBox(width: 10),

            // Icon / Avatar
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: showDiscussionCard
                  ? const Icon(Icons.chat_bubble_outline,
                      color: Colors.white, key: ValueKey('chat'))
                  : Container(
                      key: const ValueKey('initial'),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          widget.paper['name']?.isNotEmpty == true
                              ? widget.paper['name'][0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Paper Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showDiscussionCard
                        ? "Discussion Available"
                        : widget.paper['name'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 2),
                  showDiscussionCard
                      ? Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -10,
                              right: -30,
                              child: RepeatingThumbAnimation(RiveThumb.tap),
                            ),
                            Text(
                              "Join the conversation",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12.5),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Text(
                              "Year: ${widget.paper['academicYear'] ?? 'N/A'}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12.5),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Type: ${widget.paper['type'] ?? 'Unknown'}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12.5),
                            ),
                          ],
                        ),
                ],
              ),
            ),

            // Arrow
            if (!widget.isLast) const SizedBox(width: 12),
            if (!widget.isLast)
              const Icon(Icons.arrow_forward_ios,
                  size: 18, color: Color.fromARGB(255, 206, 205, 205)),
          ],
        ),
      ),
    );
  }
}
