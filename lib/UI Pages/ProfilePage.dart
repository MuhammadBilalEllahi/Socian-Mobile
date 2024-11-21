import 'package:flutter/material.dart';

import 'Profile Page Widgets/AboutMeProfile.dart';
import 'Profile Page Widgets/CarouselProfilePage.dart';
import 'Profile Page Widgets/ProfileIdentity.dart';
import 'Profile Page Widgets/StatsBoxProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        // color: Colors.lightGreenAccent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenWidth/16,),
              Row(mainAxisAlignment:MainAxisAlignment.end, children: [Icon(Icons.more_horiz),SizedBox(width: 5,)],),
              ProfileIdentity(),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatsBoxProfile(),
                ],
              ),
          
              SizedBox(height: 15,),
          
              // About Me
              SingleChildScrollView(
          
                  scrollDirection: Axis.horizontal,
                  child: Row(
                children: [
                  AboutMeProfile(),
                  // AboutMeProfile(),
                  // AboutMeProfile(),
                ],
              )),
              Text("Highlights",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
              CarouselProfilePage(),
              SizedBox(height: 10,),
              Text("Posts",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),

              SizedBox(height: 150,),
            ],

          ),
        ),
      ),
    );
  }
}










