import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import '../CreatePost.dart';
import 'location_text_selector.dart';

class UserInfoSection extends ConsumerWidget {
  final PostType postType;
  final String? selectedLocation;
  final Function(String?) onLocationSelected;
  final Function() onLocationCleared;

  const UserInfoSection({
    super.key,
    required this.postType,
    required this.selectedLocation,
    required this.onLocationSelected,
    required this.onLocationCleared,
  });

  void _showLocationTextSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LocationTextSelector(
        selectedLocation: selectedLocation,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: user?['photoUrl'] != null
                    ? NetworkImage(user!['photoUrl'] as String)
                    : null,
                child: user?['photoUrl'] == null
                    ? Text(
                        (user?['name'] as String?)?[0].toUpperCase() ?? 'U',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?['name'] as String? ?? 'User',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      user?['email'] as String? ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (postType == PostType.personal) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showLocationTextSelector(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedLocation ?? 'Add location',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selectedLocation != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: selectedLocation != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    if (selectedLocation != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onLocationCleared,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 