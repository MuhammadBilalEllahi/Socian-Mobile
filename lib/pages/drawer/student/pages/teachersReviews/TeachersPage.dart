import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/components/_buildShimmerEffect.dart';
import 'package:socian/core/utils/rbac.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';

import 'TeacherDetailsPage.dart';
import 'TeachersProvider.dart'; // import the provider

class TeachersPage extends ConsumerStatefulWidget {
  const TeachersPage({super.key});

  @override
  ConsumerState<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends ConsumerState<TeachersPage> {
  TextEditingController searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  final _reasonController = TextEditingController();

  Widget _hideReasonDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const Text('Hide Reason - Do not Make Mistakes',
          style: TextStyle(fontSize: 16, color: Colors.red)),
      content: TextFormField(
        controller: _reasonController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter reason for hiding',
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a reason';
          }
          return null;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, _reasonController.text.trim()),
          child: Text('Submit',
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
        ),
      ],
    );
  }

  Future<void> _handleHideTeacher(String teacherId) async {
    print("______________________\n _______________\n $teacherId");
    // Handle hide
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _hideReasonDialog(),
    );
    if (reason == null) return;
    final apiClient = ApiClient();
    try {
      final response = await apiClient.put(
        '/api/mod/teacher/hide?teacherId=$teacherId',
        {
          'reason': reason,
        },
      );
      if (response.isNotEmpty) {
        showSnackbar(context, response['message'], isError: false);
      }
    } catch (e) {
      showSnackbar(context, e.toString(), isError: true);
    }
  }

  Widget _unHideReasonDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const Text('Unhide Reason - Do not Make Mistakes',
          style: TextStyle(fontSize: 16, color: Colors.green)),
      content: TextFormField(
        controller: _reasonController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter reason for unhiding',
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a reason';
          }
          return null;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, _reasonController.text.trim()),
          child: Text('Submit',
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
        ),
      ],
    );
  }

  Future<void> _handleUnHideTeacher(String teacherId) async {
    print("______________________\n _______________\n $teacherId");
    // Handle hide
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _unHideReasonDialog(),
    );
    if (reason == null) return;
    final apiClient = ApiClient();
    try {
      final response = await apiClient.put(
        '/api/mod/teacher/un-hide?teacherId=$teacherId',
        {
          'reason': reason,
        },
      );
      if (response.isNotEmpty) {
        showSnackbar(context, response['message'], isError: false);
      }
    } catch (e) {
      showSnackbar(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final teachersState = ref.watch(teachersProvider);
    final notifier = ref.read(teachersProvider.notifier);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Campus Faculty',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: notifier.filterTeachers,
              decoration: InputDecoration(
                hintText: 'Search teachers...',
                prefixIcon: Icon(Icons.search,
                    color: isDark ? Colors.white70 : Colors.black54),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await notifier.fetchTeachers();
              },
              child: Builder(
                builder: (context) {
                  if (teachersState.isLoading) {
                    return buildShimmerEffect(itemCount: 10);
                  } else if (teachersState.error != null) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(
                              'Error: ${teachersState.error}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (teachersState.filteredTeachers.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(
                              'No teachers found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final teachers = teachersState.filteredTeachers;

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TeacherCard(
                          teacher: teacher,
                          name: teacher['name'] ?? 'N/A',
                          department: teacher['department']['name'] ?? 'N/A',
                          imageUrl: teacher['imageUrl'],
                          rating: teacher['rating']?.toDouble() ?? 0.0,
                          topFeedback: teacher['topFeedback'],
                          subjects: List<String>.from(
                              teacher['subjectsTaught'] ?? []),
                          onHide: RBAC.hasPermission(
                                  user,
                                  Permissions.moderator[
                                      ModeratorPermissionsEnum.hidePost.name]!)
                              ? () => _handleHideTeacher(teacher['_id'])
                              : null,
                          onUnHide: RBAC.hasPermission(
                                  user,
                                  Permissions.moderator[
                                      ModeratorPermissionsEnum.hidePost.name]!)
                              ? () => _handleUnHideTeacher(teacher['_id'])
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final String name;
  final String department;
  final String? imageUrl;
  final double rating;
  final String? topFeedback;
  final List<String> subjects;
  final VoidCallback? onHide;
  final VoidCallback? onUnHide;
  const _TeacherCard({
    required this.teacher,
    required this.name,
    required this.department,
    this.imageUrl,
    required this.rating,
    this.topFeedback,
    required this.subjects,
    this.onHide,
    this.onUnHide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherDetailsPage(teacher: teacher),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(imageUrl: imageUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (onHide != null)
                            IconButton(
                              icon: Icon(
                                Icons.visibility_off,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              onPressed: onHide,
                              tooltip: 'Hide teacher',
                            ),
                          if (onUnHide != null)
                            IconButton(
                              icon: Icon(
                                Icons.visibility,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              onPressed: onUnHide,
                              tooltip: 'Unhide teacher',
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        department,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (subjects.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: subjects
                              .map((subject) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      subject,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (topFeedback != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '"$topFeedback"',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1,
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
          size: 32,
          color: isDark
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}
