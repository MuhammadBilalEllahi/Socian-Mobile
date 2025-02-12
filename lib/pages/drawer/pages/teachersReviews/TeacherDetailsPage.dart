import 'package:flutter/material.dart';

class TeacherDetailsPage extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // for dark mode
        : Colors.teal;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(

          'Teacher Details',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(imageUrl: teacher['imageUrl']),
            const SizedBox(height: 20),
            Text(
              teacher['name'] ?? 'N/A',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              teacher['department']['name'] ?? 'N/A',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: 'Contact',
              textColor: textColor,
              children: [
                _DetailItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: teacher['email'] ?? 'N/A', textColor: textColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: 'Rating',
              textColor: textColor,
              children: [
                _DetailItem(
                  icon: Icons.star,
                  label: 'Overall Rating',
                  value: teacher['rating']?.toString() ?? '0.0',
                  textColor: textColor,
                ),
                if (teacher['topFeedback'] != null)
                  _DetailItem(
                    icon: Icons.comment,
                    label: 'Top Feedback',
                    value: teacher['topFeedback'],
                    textColor: textColor,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (teacher['subjectsTaught'] != null && teacher['subjectsTaught'].isNotEmpty)
              _DetailSection(
                title: 'Subjects Taught',
                textColor: textColor,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (teacher['subjectsTaught'] as List<dynamic>)
                        .map((subject) => Chip(
                      label: Text(
                        subject.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ))
                        .toList(),
                  ),
                ],
              ),
          ],
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
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A9D8F), Color(0xFF264653)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.white),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {

  final String title;
  final List<Widget> children;
  final Color textColor;

  const _DetailSection({required this.title, required this.children, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textColor;


  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value, 
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}