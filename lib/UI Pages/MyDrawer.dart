import 'package:beyondtheclass/UI%20Pages/PastPapers.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends ConsumerState<MyDrawer> {
  


  
  @override
  Widget build(BuildContext context) {

    
    final auth = ref.watch(authProvider);

// UNDERSTAND Left this for you to understand
//     print("auh $auth");

//   print('Auth data: ${auth.user ?? "No user data"}');

//   print('Auth name: ${auth.user?['name'] ?? "No name"}');
// print('Auth email: ${auth.user?['email'] ?? "No email"}');

  // print('Auth email: ${auth.user?.email ?? "No email"}');
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.tealAccent.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Drawer Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 0, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_sharp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${'${AppConstants.appGreeting} '+auth.user?['name']}!",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Text(
                  //   AppConstants.appName,
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Colors.white
                  //   ),
                  // ),
                ],
              ),
            ),

            // const Divider(color: Colors.white70, thickness: 1),

            // Drawer Options
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Text(
                      '🏠', // Emoji for Home (House)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text("Home", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.person, color: Colors.white),
                    leading: const Text(
                      '🏛️', // Emoji for All Unis (Classical Building)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text("All Unis", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),ListTile(
                    // leading: Icon(Icons.person, color: Colors.white),
                    leading: const Text(
                      '🏫', // Emoji for All Unis (Classical Building)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text("Inter Campuses", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.notifications, color: Colors.white),
                    leading: const Text(
                      '👨‍🎓', // Emoji for alumni
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text("Alumni", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),ListTile(
                    // leading: Icon(Icons.notifications, color: Colors.white),
                    leading: const Text(
                      '👨‍🏫', // Emoji for alumni
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text("Teacher's Reviews", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Text(
                      '☕', // Emoji for Cafe Information Services (Coffee Cup)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text("Cafe Information Services", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Text(
                      '📄', // Emoji for Past Papers (Document)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: GestureDetector(child: const Text("Past Papers", style: TextStyle(color: Colors.white))),
                    onTap: () {
                      Navigator.pushNamed(
                      context,
                      '/pastpaper'
                      );
                      },
                  ),
                ],
              ),
            ),

            // const Divider(color: Colors.white70, thickness: 1),

            // Footer
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Text(
            //     "Version 1.0.0",
            //     style: TextStyle(
            //       color: Colors.teal.shade200,
            //       fontSize: 12,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
