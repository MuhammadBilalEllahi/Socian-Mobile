import 'package:flutter/material.dart';

import 'MessageCard.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: 40,
                    child: Icon(Icons.menu_outlined),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // color: Colors.red,
                  // height: 30,
                  // width: 80,
                  child: Text("Inbox",style: TextStyle(color: Colors.teal.shade900,fontSize: 28,fontWeight: FontWeight.bold),),
                )
              ],
            ),
            // Add MessageCard widgets
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Mohammad Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Muhammmad Rayyan',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Mohammad Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Muhammmad Rayyan',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Mohammad Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Muhammmad Rayyan',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Mohammad Bilal Ellahi',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),
            MessageCard(
              picture: 'assets/images/anime.png', // Replace with your image URL or asset path
              name: 'Muhammmad Rayyan',
              message: 'Hey there! How are you doing today?',
              time: '2:45 PM',
            ),

          ],

        ),
      ),
    );
  }
}
