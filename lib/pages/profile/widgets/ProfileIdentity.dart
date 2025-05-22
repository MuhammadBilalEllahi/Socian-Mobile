import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileIdentity extends ConsumerStatefulWidget {
  const ProfileIdentity({super.key});

  @override
  _ProfileIdentityState createState() => _ProfileIdentityState();
}

class _ProfileIdentityState extends ConsumerState<ProfileIdentity> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    const primary = Color(0xFF8B5CF6);
    final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Container(
      // color: Colors.red,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primary,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: accent,
              backgroundImage: auth.user?['profile']['picture'] != null
                  ? NetworkImage(auth.user?['profile']['picture'])
                  : const AssetImage("assets/images/profilepic2.jpg")
                      as ImageProvider,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            auth.user?['name'] ?? "Logged Out",
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "@${auth.user?['username'] ?? "Logged Out"}",
            style: TextStyle(
              color: mutedForeground,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
