import 'package:flutter/material.dart';
import '../create_post.dart';

class PostTypeSelector extends StatelessWidget {
  final PostType selectedType;
  final Function(PostType) onTypeChanged;

  const PostTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.category_outlined,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Post Type:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PostType>(
                value: selectedType,
                isDense: true,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(16),
                dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                items: [
                  DropdownMenuItem(
                    value: PostType.personal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Personal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: PostType.society,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Society',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onTypeChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 