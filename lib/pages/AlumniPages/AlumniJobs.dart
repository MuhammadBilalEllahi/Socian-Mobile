import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';

class AlumniJobs extends ConsumerWidget {
  const AlumniJobs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Opportunities'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // Replace with actual job count
        itemBuilder: (context, index) {
          return const Card(
            child: ListTile(
              title: Text('No job postings yet'),
              subtitle: Text('Job opportunities will appear here'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement job posting
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 