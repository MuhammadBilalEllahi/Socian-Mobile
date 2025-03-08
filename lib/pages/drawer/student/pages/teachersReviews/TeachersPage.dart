import 'dart:ui';
import 'package:beyondtheclass/components/_buildShimmerEffect.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'TeacherDetailsPage.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final ApiClient apiClient = ApiClient();
  late Future<List<dynamic>> _teachersFuture;

  Future<List<dynamic>> fetchTeachers() async {
    try {
      final response = await apiClient.get(ApiConstants.campusTeachers);
      if (response is List) {
        return response;
      } else {
        throw 'Invalid API response format: $response';
      }
    } catch (e) {
      throw 'Failed to load teachers: $e';
    }
  }

  @override
  void initState() {
    super.initState();
    _teachersFuture = fetchTeachers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      body: FutureBuilder<List<dynamic>>(
      future: _teachersFuture,
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
      return buildShimmerEffect(itemCount: 10);
      } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No teachers found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            );
      }

      final teachers = snapshot.data!;

      return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  subjects: List<String>.from(teacher['subjectsTaught'] ?? []),
            ),
          );
        },
      );
      },
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

  const _TeacherCard({
    required this.teacher,
    required this.name,
    required this.department,
    this.imageUrl,
    required this.rating,
    this.topFeedback,
    required this.subjects,
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
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
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
                            Text(
                              name,
                        style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                              ),
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
                          children: subjects.map((subject) => Container(
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark 
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.7),
                              ),
                            ),
                          )).toList(),
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
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black,
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
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
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
          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}


