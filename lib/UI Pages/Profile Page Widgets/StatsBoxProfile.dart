// import 'package:flutter/material.dart';
//
// class StatsBoxProfile extends StatefulWidget {
//   const StatsBoxProfile({super.key});
//
//   @override
//   State<StatsBoxProfile> createState() => _StatsBoxProfileState();
// }
//
// class _StatsBoxProfileState extends State<StatsBoxProfile> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//
//       child: Container(
//         // width:screenWidth/2 ,
//         padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
//         color: Colors.teal[100],
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Connections
//             Container(
//               // width:screenWidth/4.2,
//
//               child: const Column(
//                 children: [
//                   Text("500",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.black),),
//                   Text("Connects",style: TextStyle(fontSize: 18,color: Colors.black),),
//
//                 ],
//               ),
//             ),
//             const SizedBox(height:50 , child: VerticalDivider(thickness: 2,width: 20,color: Colors.black,)),
//             // Credibility
//             Container(
//               // width:screenWidth/4.2 ,
//
//               child: const Column(
//                 children: [
//                   Text("6.9",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.black),),
//                   Text("Credibility",style: TextStyle(fontSize: 18,color: Colors.black),),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



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

    return Container(
      // margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade900,
            Colors.tealAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Connections
          Column(
            children: [
              Text(
                "500",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Connects",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(width: 5,),
          Container(
            height: 50,
            width: 3,
            color: Colors.white,
          ),
          SizedBox(width: 5,),
          // Credibility
          Column(
            children: [
              Text(
                "6.9",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Credibility",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

