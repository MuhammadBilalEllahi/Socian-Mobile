import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';

class AlumniProfile extends ConsumerWidget {
  const AlumniProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user?['profile']?['picture'] != null
                    ? NetworkImage(user!['profile']['picture'])
                    : const AssetImage('assets/images/profilepic2.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?['name'] ?? 'Alumni Name',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '@${user?['username'] ?? 'username'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            // Add more profile details here
          ],
        ),
      ),
    );
  }
} 