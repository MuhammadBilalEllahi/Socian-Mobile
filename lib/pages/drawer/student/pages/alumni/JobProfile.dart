import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/services/api_client.dart';

class JobProfile extends ConsumerStatefulWidget {
  const JobProfile({super.key});

  @override
  ConsumerState<JobProfile> createState() => _JobProfileState();
}

class _JobProfileState extends ConsumerState<JobProfile> {
  final apiClient = ApiClient();

  // Mock alumni data
  final List<Map<String, dynamic>> alumniList = [
    {
      'name': 'Natasha Romanoff',
      'verified': true,
      'description':
          'I\'m a Brand Designer who focuses on clarity & emotional connection.',
      'rating': 4.8,
      'earned': '2045k+',
      'rate': '2050/hr',
      'profileImage':
          'https://randomuser.me/api/portraits/women/68.jpg', // Replace with your asset or network image
    },
    // Add more alumni if needed
  ];

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
          'Alumni',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        itemCount: alumniList.length,
        itemBuilder: (context, index) {
          final alumni = alumniList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _AlumniCard(alumni: alumni, isDark: isDark),
          );
        },
      ),
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final Map<String, dynamic> alumni;
  final bool isDark;
  const _AlumniCard({required this.alumni, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                alumni['profileImage'],
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  alumni['name'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                if (alumni['verified'] == true) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded,
                      color: Colors.blue, size: 22),
                ]
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alumni['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoTile(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: alumni['rating'].toString(),
                  isDark: isDark,
                ),
                _InfoTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Earned',
                  value: alumni['earned'],
                  isDark: isDark,
                ),
                _InfoTile(
                  icon: Icons.access_time_rounded,
                  label: 'Rate',
                  value: alumni['rate'],
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: const Text('Get In Touch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.bookmark_border_rounded,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () {},
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: isDark ? Colors.white : Colors.black, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
