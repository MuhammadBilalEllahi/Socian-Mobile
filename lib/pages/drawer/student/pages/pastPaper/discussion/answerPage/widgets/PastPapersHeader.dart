import 'package:flutter/material.dart';
import '../components/PastPaperInfoCard.dart';

class PastPapersHeader extends StatelessWidget {
  final List<Map<String, dynamic>> papers;
  final PageController pageController;
  final Function(int) onPageChanged;

  const PastPapersHeader({
    super.key,
    required this.papers,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(
            color: border,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 80,
        child: papers.isEmpty
            ? Center(
                child: Text(
                  'No papers available',
                  style: TextStyle(
                    color: mutedForeground,
                    fontSize: 14,
                  ),
                ),
              )
            : PageView.builder(
                controller: pageController,
                itemCount: papers.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return PastPaperInfoCard(
                    paper: papers[index],
                    isFirst: index == 0,
                    isLast: index == papers.length - 1,
                    onPaperSelected: (url, name, year) {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onChatBoxToggle: () {},
                  );
                },
              ),
      ),
    );
  }
}
