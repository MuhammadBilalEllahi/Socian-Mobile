import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsBoxProfile extends ConsumerStatefulWidget {
  const StatsBoxProfile({super.key});

  @override
  _StatsBoxProfileState createState() => _StatsBoxProfileState();
}

class _StatsBoxProfileState extends ConsumerState<StatsBoxProfile> {
  @override
  Widget build(BuildContext context) {

        final auth = ref.watch(authProvider);

print("auth ${auth.user}");

var postCredibility = auth.user?['profile']['credibility']['postCredibility'] ?? 0;
var commentCredibility = auth.user?['profile']['credibility']['commentCredibility'] ?? 0;
final credibilities =  postCredibility + commentCredibility ?? 0;
print("auth credibilty }");
print("auth credibilty ${auth.user?['profile']['credibility']['commentCredibility']}");



    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade900,
            Colors.tealAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Connections
           Column(
            children: [
              Text(
                "$credibilities",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Connects",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 5,),
          Container(
            height: 50,
            width: 3,
            color: Colors.white,
          ),
          const SizedBox(width: 5,),
          // Credibility
          const Column(
            children: [
              Text(
                "6.9",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Credibility",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

