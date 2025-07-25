import 'package:flutter/material.dart';

class PostStatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final bool isActive;

  const PostStatItem({
    super.key,
    required this.icon,
    required this.count,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = icon == Icons.favorite
        ? (isActive ? Colors.red : Colors.grey[600])
        : (isActive ? Colors.blueGrey : Colors.grey[600]);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              count > 0 ? count.toString() : '',
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
