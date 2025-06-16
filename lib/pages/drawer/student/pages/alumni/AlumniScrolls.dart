import 'package:flutter/material.dart';

class AlumniScrolls extends StatefulWidget {
  const AlumniScrolls({super.key});

  @override
  State<AlumniScrolls> createState() => _AlumniScrollsState();
}

class _AlumniScrollsState extends State<AlumniScrolls> {
  final List<Map<String, dynamic>> allPeople = [
    {
      'name': 'Natasha Romanoff',
      'verified': true,
      'description':
          'Brand Designer focused on clarity & emotional connection.',
      'profileImage': 'https://randomuser.me/api/portraits/women/68.jpg',
      'graduationYear': '2018',
      'field': 'B.A. Visual Communication',
      'university': 'Stark University',
      'universityLogo':
          'https://upload.wikimedia.org/wikipedia/commons/1/1b/Logo_university.png',
      'role': 'Alumni',
    },
    {
      'name': 'Bruce Banner',
      'verified': false,
      'description': 'Researcher & Mentor in Biotech.',
      'profileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
      'graduationYear': '2015',
      'field': 'PhD, Biotechnology',
      'university': 'Gamma State College',
      'universityLogo':
          'https://upload.wikimedia.org/wikipedia/commons/1/1b/Logo_university.png',
      'role': 'Alumni',
    },
    {
      'name': 'Carol Danvers',
      'verified': true,
      'description': 'Aerospace Engineer & Motivational Speaker.',
      'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'graduationYear': '2012',
      'field': 'B.Sc. Aerospace Engineering',
      'university': 'Pegasus Institute',
      'universityLogo':
          'https://upload.wikimedia.org/wikipedia/commons/1/1b/Logo_university.png',
      'role': 'Alumni',
    },
    {
      'name': 'Peter Parker',
      'verified': false,
      'description': 'Computer Science Student & Photographer.',
      'profileImage': 'https://randomuser.me/api/portraits/men/83.jpg',
      'graduationYear': '2025',
      'field': 'B.Sc. Computer Science',
      'university': 'Empire State University',
      'universityLogo':
          'https://upload.wikimedia.org/wikipedia/commons/1/1b/Logo_university.png',
      'role': 'Student',
    },
    {
      'name': 'Stephen Strange',
      'verified': true,
      'description': 'Professor of Surgery & Medical Consultant.',
      'profileImage': 'https://randomuser.me/api/portraits/men/52.jpg',
      'graduationYear': '2008',
      'field': 'MD, Surgery',
      'university': 'Kamar-Taj Medical College',
      'universityLogo':
          'https://upload.wikimedia.org/wikipedia/commons/1/1b/Logo_university.png',
      'role': 'Teacher',
    },
  ];

  String searchQuery = '';
  String selectedRole = 'Alumni';
  final List<String> roles = ['Alumni', 'Student', 'Teacher'];

  List<Map<String, dynamic>> get filteredPeople {
    return allPeople.where((person) {
      final matchesRole = person['role'] == selectedRole;
      final matchesQuery =
          person['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesRole && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.black;
    final overlayColor =
        isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: overlayColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: dividerColor, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Icon(Icons.search, color: subTextColor, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Search alumni...',
                                hintStyle: TextStyle(
                                    color: subTextColor, fontFamily: 'Inter'),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) =>
                                  setState(() => searchQuery = val),
                            ),
                          ),
                          // Filter button
                          _FilterButton(
                            value: selectedRole,
                            options: roles,
                            onChanged: (val) =>
                                setState(() => selectedRole = val),
                            fgColor: fgColor,
                            bgColor: bgColor,
                            borderColor: dividerColor,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Alumni badge at the top center
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dividerColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        selectedRole,
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // List of alumni cards
            Expanded(
              child: filteredPeople.isEmpty
                  ? Center(
                      child: Text(
                        'No $selectedRole found.',
                        style: TextStyle(
                            color: subTextColor,
                            fontSize: 16,
                            fontFamily: 'Inter'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filteredPeople.length,
                      itemBuilder: (context, index) {
                        final alumni = filteredPeople[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _AlumniCard(
                            alumni: alumni,
                            isDark: isDark,
                            bgColor: bgColor,
                            fgColor: fgColor,
                            subTextColor: subTextColor,
                            dividerColor: dividerColor,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final Map<String, dynamic> alumni;
  final bool isDark;
  final Color bgColor;
  final Color fgColor;
  final Color subTextColor;
  final Color dividerColor;
  const _AlumniCard(
      {required this.alumni,
      required this.isDark,
      required this.bgColor,
      required this.fgColor,
      required this.subTextColor,
      required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: dividerColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white10 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Image.network(
                  alumni['profileImage'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // University logo and name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: bgColor,
                  backgroundImage: NetworkImage(alumni['universityLogo']),
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Text(
                  alumni['university'],
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Name and verified
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  alumni['name'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fgColor,
                    letterSpacing: -1.2,
                    fontFamily: 'Inter',
                  ),
                ),
                if (alumni['verified'] == true) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded,
                      color: Colors.blue, size: 20),
                ]
              ],
            ),
            const SizedBox(height: 6),
            // Graduation year and field
            Text(
              '${alumni['field']} • Class of ${alumni['graduationYear']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subTextColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Divider
            Container(
              height: 1.2,
              width: 50,
              color: dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            // Description
            Text(
              alumni['description'],
              style: theme.textTheme.bodyLarge?.copyWith(
                color: subTextColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _ShadcnButton(
              text: 'Connect with ${alumni['role']}',
              onTap: () {},
              fgColor: bgColor,
              bgColor: fgColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color fgColor;
  final Color bgColor;
  const _ShadcnButton(
      {required this.text,
      required this.onTap,
      required this.fgColor,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: fgColor, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Inter',
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final Color fgColor;
  final Color bgColor;
  final Color borderColor;
  const _FilterButton(
      {required this.value,
      required this.options,
      required this.onChanged,
      required this.fgColor,
      required this.bgColor,
      required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => options
          .map((role) => PopupMenuItem<String>(
                value: role,
                child: Text(role,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: fgColor, size: 18),
          ],
        ),
      ),
    );
  }
}
