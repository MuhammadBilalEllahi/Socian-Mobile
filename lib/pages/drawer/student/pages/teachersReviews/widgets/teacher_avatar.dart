import 'package:flutter/material.dart';

class TeacherAvatar extends StatelessWidget {
  final String? imageUrl;

  const TeacherAvatar({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _FallbackAvatar(),
              )
            : const _FallbackAvatar(),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
            : [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.05)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
} 