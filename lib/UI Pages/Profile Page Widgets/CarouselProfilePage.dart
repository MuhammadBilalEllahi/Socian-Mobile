import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselProfilePage extends StatefulWidget {
  const CarouselProfilePage({super.key});

  @override
  State<CarouselProfilePage> createState() => _CarouselProfilePageState();
}

class _CarouselProfilePageState extends State<CarouselProfilePage> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(

      options: CarouselOptions(
          // height: 400.0,
        autoPlay: true,
        enableInfiniteScroll: true,

        autoPlayInterval: const Duration(seconds: 1),
        autoPlayAnimationDuration: const Duration(milliseconds: 2000),


      ),
      items: ["assets/images/profilepic2.jpg","assets/images/profilepic.jpg","assets/images/anime.png","assets/images/anime2.png"].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                  width: MediaQuery.of(context).size.width/1.2,
                  height: MediaQuery.of(context).size.height/4,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: const BoxDecoration(
                      color: Colors.transparent
                  ),
                  child: Image.asset(i,fit:
                  BoxFit.cover, // Ensures the image fits the parent
                    width: double.infinity,
                    height: double.infinity,
                  )
              ),
            );
          },
        );
      }).toList(),
    );
  }
}












