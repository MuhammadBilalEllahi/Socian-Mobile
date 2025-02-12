import 'package:flutter/material.dart';

import 'widgets/AboutMeProfile.dart';
import 'widgets/CarouselProfilePage.dart';
import 'widgets/ProfileDropDown.dart';
import 'widgets/ProfileIdentity.dart';
import 'widgets/StatsBoxProfile.dart';

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

              const ProfileDropDown(),

              const ProfileIdentity(),
              const SizedBox(height: 15,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatsBoxProfile(),
                ],
              ),
          
              const SizedBox(height: 15,),
          
              // About Me
              const SingleChildScrollView(
          
                  scrollDirection: Axis.horizontal,
                  child: Row(
                children: [
                  AboutMeProfile(),
                  // AboutMeProfile(),
                  // AboutMeProfile(),
                ],
              )),
              const Text("Highlights",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
              const CarouselProfilePage(),
              const SizedBox(height: 10,),
              const Text("Posts",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),

              const SizedBox(height: 150,),
            ],

          ),
        ),
      ),
    );
  }
}










