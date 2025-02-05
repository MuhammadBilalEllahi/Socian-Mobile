import 'dart:ui';
import 'package:flutter/material.dart';
import '../../components/_buildShimmerEffect.dart';
import '../../core/utils/constants.dart';
import '../../shared/services/api_client.dart';
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

    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // for dark mode
        : Colors.teal;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text('Campus Faculty',
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<List<dynamic>>(
      future: _teachersFuture,
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
      return buildShimmerEffect(itemCount: 10);
      } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('No teachers found', style: TextStyle(color: textColor)));
      }

      final teachers = snapshot.data!;

      return ListView.builder(
        padding: const EdgeInsets.only(top: 100, bottom: 16),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8),
            child: _TeacherCard(
              teacher: teacher,
              name: teacher['name'] ?? 'N/A',
              department: teacher['department']['name'] ?? 'N/A',
              imageUrl: teacher['imageUrl'],
              rating: teacher['rating']?.toDouble() ?? 0.0,
              topFeedback: teacher['topFeedback'],
              subjects: List<String>.from(
                  teacher['subjectsTaught'] ?? []),
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

    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // for dark mode
        : Colors.teal;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // color: Colors.white.withOpacity(0.1),
        color: Colors.white.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherDetailsPage(teacher: teacher),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(imageUrl: imageUrl),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              department,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
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
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                    Colors.white.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    subject,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
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
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE9C46A),
                                        Color(0xFFF4A261),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star_rounded,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.white,
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
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
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackAvatar(),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A9D8F), Color(0xFF264653)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 36, color: Colors.white),
      ),
    );
  }
}

