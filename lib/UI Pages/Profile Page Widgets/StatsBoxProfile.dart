import 'package:flutter/material.dart';

class StatsBoxProfile extends StatefulWidget {
  const StatsBoxProfile({super.key});

  @override
  State<StatsBoxProfile> createState() => _StatsBoxProfileState();
}

class _StatsBoxProfileState extends State<StatsBoxProfile> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),

      child: Container(
        // width:screenWidth/2 ,
        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        color: Colors.teal[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connections
            Container(
              // width:screenWidth/4.2,

              child: Column(
                children: [
                  Text("500",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.black),),
                  Text("Connects",style: TextStyle(fontSize: 18,color: Colors.black),),

                ],
              ),
            ),
            Container(height:50 , child: VerticalDivider(thickness: 2,width: 20,color: Colors.black,)),
            // Credibility
            Container(
              // width:screenWidth/4.2 ,

              child: Column(
                children: [
                  Text("6.9",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.black),),
                  Text("Credibility",style: TextStyle(fontSize: 18,color: Colors.black),),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
