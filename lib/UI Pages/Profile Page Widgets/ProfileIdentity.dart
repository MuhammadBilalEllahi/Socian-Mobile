import 'package:flutter/material.dart';

class ProfileIdentity extends StatefulWidget {
  const ProfileIdentity({super.key});

  @override
  State<ProfileIdentity> createState() => _ProfileIdentityState();
}

class _ProfileIdentityState extends State<ProfileIdentity> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.tealAccent, // Border color
                  width: 4,           // Border thickness
                ),
              ),
              child: CircleAvatar(radius: 80,backgroundImage: AssetImage("assets/images/profilepic2.jpg"),)),
          Text("Muhammad Rayyan", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          Text("@rayyan123",style: TextStyle(color: Colors.grey[850],fontSize: 14),),
        ],
      ),
    );
  }
}
