import 'package:flutter/material.dart';

class AboutMeProfile extends StatefulWidget {
  const AboutMeProfile({super.key});

  @override
  State<AboutMeProfile> createState() => _AboutMeProfileState();
}

class _AboutMeProfileState extends State<AboutMeProfile> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          alignment: Alignment.centerLeft,

          decoration: BoxDecoration(
            // color: Colors.blueGrey[200],
            color: Colors.transparent,
            border: Border.all(
              // color: Colors.grey,
              width: 2,
              color: Colors.teal
            ),
          ),
          width: screenWidth / 1.1,
          height: 200,
          child: const Center(child: Text("Welcome To My Profile. Lorem Ipsum este pur şi simplu o machetă pentru text a industriei tipografice.",textAlign: TextAlign.center, style: TextStyle(fontSize: 20,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)),
        ),
      ),
    );
  }
}
