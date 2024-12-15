import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade800],
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
                    backgroundColor: Colors.teal.shade800,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.teal.shade100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Good Day, User!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Text(
                  //   "Beyond The Class",
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
                    leading: Text(
                      '🏠', // Emoji for Home (House)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text("Home", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.person, color: Colors.white),
                    leading: Text(
                      '🏛️', // Emoji for All Unis (Classical Building)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text("All Unis", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    // leading: Icon(Icons.notifications, color: Colors.white),
                    leading: Text(
                      '👨‍🎓', // Emoji for alumni
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text("Alumni", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Text(
                      '☕', // Emoji for Cafe Information Services (Coffee Cup)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text("Cafe Information Services", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Text(
                      '📄', // Emoji for Past Papers (Document)
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text("Past Papers", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).pop();
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
