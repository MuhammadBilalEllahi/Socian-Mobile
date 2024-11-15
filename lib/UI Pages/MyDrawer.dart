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
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.transparent.withOpacity(0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Drawer Button
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_ios_sharp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Drawer Options
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                // Navigate to Home Page
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("All Unis"),
              onTap: () {
                // Navigate to Profile Page
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Alumni"),
              onTap: () {
                // Navigate to Notifications Page
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood_outlined),
              title: Text("Cafe Information Services"),
              onTap: () {
                // Navigate to Settings Page
                Navigator.of(context).pop();
              },
            ),

            ListTile(
              leading: Icon(Icons.document_scanner_outlined),
              title: Text("Past Paper"),
              onTap: () {
                // Handle Log Out
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

