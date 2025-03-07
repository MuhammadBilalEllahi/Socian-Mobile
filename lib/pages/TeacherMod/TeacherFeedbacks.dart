import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';

class TeacherFeedbacks extends ConsumerWidget {
  const TeacherFeedbacks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Feedbacks'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // Replace with actual feedback count
        itemBuilder: (context, index) {
          return const Card(
            child: ListTile(
              title: Text('No feedbacks yet'),
              subtitle: Text('Student feedbacks will appear here'),
            ),
          );
        },
      ),
    );
  }
} 