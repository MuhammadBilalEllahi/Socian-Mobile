import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
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


    return Container(
      // color: Colors.red,
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.tealAccent, // Border color
                  width: 4, // Border thickness
                ),
              ),
              child: CircleAvatar(
                radius: 80,
                backgroundImage: auth.user?['profile']['picture'] != null
                    ? NetworkImage(auth.user?['profile']['picture'])
                    : const AssetImage("assets/images/profilepic2.jpg")
                        as ImageProvider,
              )),
          Text(
            auth.user?['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            "@${auth.user?['username']}",
            style: TextStyle(color: Colors.grey[850], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
