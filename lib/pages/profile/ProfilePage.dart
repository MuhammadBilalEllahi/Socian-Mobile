// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/core/utils/constants.dart';

// class ProfilePage extends ConsumerStatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String _selectedReviewFilter = 'All';

//   // Sample repost data
//   final List<Map<String, dynamic>> reposts = [
//     {
//       "originalPoster": "John Doe", 
//       "username": "@johndoe",
//       "content": "Just discovered an amazing study spot in the library! Perfect lighting and super quiet.",
//       "date": "2024-01-15",
//       "likes": 45,
//       "comments": 12
//     },
//     {
//       "originalPoster": "Jane Smith",
//       "username": "@jsmith", 
//       "content": "Great turnout at today's CS Society meetup! Thanks everyone who came.",
//       "date": "2024-01-14",
//       "likes": 32,
//       "comments": 8
//     }
//   ];

//   // Sample posts data
//   final List<Map<String, dynamic>> posts = [
//     {
//       "type": "society",
//       "societyName": "Computer Science Society",
//       "content": "Next week's hackathon is going to be amazing! Don't forget to register.",
//       "date": "2024-01-16", 
//       "likes": 56,
//       "comments": 23
//     },
//     {
//       "type": "personal",
//       "content": "Finally finished my thesis! Time to celebrate!",
//       "date": "2024-01-15",
//       "likes": 89,
//       "comments": 34
//     }
//   ];

//   // Sample societies data
//   final List<Map<String, dynamic>> societies = [
//     {
//       "name": "Computer Science Society",
//       "description": "A community for CS enthusiasts to learn, network and grow together. Regular hackathons, coding workshops and industry talks.",
//       "members": 250,
//       "activities": ["Hackathons", "Tech Talks", "Coding Workshops", "Industry Visits"],
//       "benefits": ["Technical skill development", "Networking", "Project experience", "Industry exposure"]
//     },
//     {
//       "name": "Entrepreneurship Club",
//       "description": "Platform for aspiring entrepreneurs to develop business ideas, meet co-founders and learn from successful founders.",
//       "members": 180,
//       "activities": ["Startup Weekends", "Pitch Competitions", "Mentorship Sessions", "Networking Events"],
//       "benefits": ["Business skills", "Leadership experience", "Startup exposure", "Mentorship"]
//     },
//     {
//       "name": "Debate Society",
//       "description": "Enhance your public speaking and critical thinking skills through competitive debating and discussions.",
//       "members": 120,
//       "activities": ["Inter-university Debates", "Public Speaking Workshops", "Mock Debates", "Speech Competitions"],
//       "benefits": ["Communication skills", "Critical thinking", "Confidence building", "Competition experience"]
//     },
//     {
//       "name": "Photography Club",
//       "description": "Express creativity through photography. Learn techniques, participate in exhibitions and build your portfolio.",
//       "members": 150,
//       "activities": ["Photo Walks", "Equipment Workshops", "Exhibitions", "Competitions"],
//       "benefits": ["Creative skills", "Technical knowledge", "Portfolio building", "Exhibition experience"]
//     }
//   ];

//   // Sample jobs data
//   final List<Map<String, dynamic>> jobs = [
//     {
//       "type": "Freelance",
//       "title": "Mobile App Developer",
//       "company": "Tech Startup",
//       "description": "Looking for a Flutter developer to build a social media app",
//       "budget": "\$2000-\$3000",
//       "duration": "2 months",
//       "skills": ["Flutter", "Firebase", "UI/UX"],
//       "postedDate": "2024-01-15"
//     },
//     {
//       "type": "Contract", 
//       "title": "Web Developer",
//       "company": "Digital Agency",
//       "description": "6-month contract for full-stack development",
//       "salary": "\$5000/month",
//       "location": "Remote",
//       "skills": ["React", "Node.js", "MongoDB"],
//       "postedDate": "2024-01-14"
//     },
//     {
//       "type": "Task",
//       "title": "Logo Design",
//       "client": "Local Business", 
//       "description": "Need a modern logo for a cafe",
//       "budget": "\$200",
//       "deadline": "1 week",
//       "skills": ["Graphic Design", "Illustrator"],
//       "postedDate": "2024-01-16"
//     }
//   ];

//   // Sample review data
//   final List<Map<String, dynamic>> cafeReviews = [
//     {
//       "foodItem": "Chicken Sandwich",
//       "cafeName": "Campus Cafe",
//       "rating": 4.5,
//       "review": "Amazing sandwich! Great value for money. The chicken was perfectly cooked.",
//       "date": "2024-01-15",
//       "foodItems": ["Lunch", "Sandwich", "Popular"]
//     },
//     {
//       "foodItem": "Pancakes",
//       "cafeName": "Campus Cafe", 
//       "rating": 4.0,
//       "review": "Fluffy pancakes with great maple syrup. Perfect breakfast option.",
//       "date": "2024-01-14",
//       "foodItems": ["Breakfast", "Sweet", "Vegetarian"]
//     },
//     {
//       "foodItem": "Margherita Pizza",
//       "cafeName": "Campus Cafe",
//       "rating": 4.8,
//       "review": "Best pizza on campus, thin crust and fresh toppings. Highly recommended!",
//       "date": "2024-01-13",
//       "foodItems": ["Pizza", "Lunch", "Vegetarian"]
//     },
//     {
//       "foodItem": "Classic Burger",
//       "cafeName": "Campus Cafe",
//       "rating": 4.2,
//       "review": "Juicy burger with fresh ingredients. Quick service!",
//       "date": "2024-01-12",
//       "foodItems": ["Burger", "Lunch", "Popular"]
//     }
//   ];

//   @override
//   void initState() {
//     _tabController = TabController(length: 6, vsync: this);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Widget _buildRepostsTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: reposts.length,
//       itemBuilder: (context, index) {
//         final repost = reposts[index];
//         return Card(
//           color: accent,
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: border),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.repeat, color: Colors.grey, size: 16),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Reposted from ${repost["originalPoster"]}',
//                       style: TextStyle(color: mutedForeground, fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   repost["username"],
//                   style: TextStyle(color: mutedForeground, fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   repost["content"],
//                   style: TextStyle(color: foreground),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       repost["date"],
//                       style: TextStyle(color: mutedForeground, fontSize: 12),
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.favorite, color: Color(0xFFEC4899), size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           repost["likes"].toString(),
//                           style: TextStyle(color: foreground),
//                         ),
//                         const SizedBox(width: 16),
//                         Icon(Icons.comment, color: mutedForeground, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           repost["comments"].toString(),
//                           style: TextStyle(color: foreground),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPostsTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: posts.length,
//       itemBuilder: (context, index) {
//         final post = posts[index];
//         return Card(
//           color: accent,
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: border),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (post["type"] == "society")
//                   Text(
//                     post["societyName"],
//                     style: const TextStyle(
//                       color: Color(0xFF8B5CF6),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 const SizedBox(height: 8),
//                 Text(
//                   post["content"],
//                   style: TextStyle(color: foreground),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       post["date"],
//                       style: TextStyle(color: mutedForeground, fontSize: 12),
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.favorite, color: Color(0xFFEC4899), size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           post["likes"].toString(),
//                           style: TextStyle(color: foreground),
//                         ),
//                         const SizedBox(width: 16),
//                         Icon(Icons.comment, color: mutedForeground, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           post["comments"].toString(),
//                           style: TextStyle(color: foreground),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSocietyTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent, Color primary) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: societies.length,
//       itemBuilder: (context, index) {
//         final society = societies[index];
//         return Card(
//           color: accent,
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: border),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       society["name"],
//                       style: TextStyle(
//                         color: foreground,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: primary,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${society["members"]} members',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   society["description"],
//                   style: TextStyle(color: mutedForeground),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Activities:',
//                   style: TextStyle(
//                     color: foreground,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: (society["activities"] as List<String>).map((activity) => Chip(
//                     label: Text(
//                       activity,
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                     backgroundColor: Colors.grey[800],
//                     labelStyle: const TextStyle(color: Colors.white),
//                   )).toList(),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Benefits:',
//                   style: TextStyle(
//                     color: foreground,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: (society["benefits"] as List<String>).map((benefit) => Chip(
//                     label: Text(
//                       benefit,
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                     backgroundColor: Colors.green[900],
//                     labelStyle: const TextStyle(color: Colors.white),
//                   )).toList(),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle join society
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primary,
//                     minimumSize: const Size(double.infinity, 40),
//                   ),
//                   child: const Text('Join Society'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildJobsTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent, Color primary) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: jobs.length,
//       itemBuilder: (context, index) {
//         final job = jobs[index];
//         return Card(
//           color: accent,
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: border),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: job["type"] == "Freelance" 
//                       ? primary
//                       : job["type"] == "Contract" 
//                         ? Colors.green[900]
//                         : Colors.orange[900],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     job["type"],
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   job["title"],
//                   style: TextStyle(
//                     color: foreground,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   job["company"] ?? job["client"],
//                   style: TextStyle(color: mutedForeground),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   job["description"],
//                   style: TextStyle(color: mutedForeground),
//                 ),
//                 const SizedBox(height: 12),
//                 if (job["budget"] != null)
//                   Row(
//                     children: [
//                       const Icon(Icons.attach_money, color: Colors.green, size: 16),
//                       Text(
//                         job["budget"],
//                         style: TextStyle(color: foreground),
//                       ),
//                     ],
//                   ),
//                 if (job["salary"] != null)
//                   Row(
//                     children: [
//                       const Icon(Icons.payments, color: Colors.green, size: 16),
//                       Text(
//                         job["salary"],
//                         style: TextStyle(color: foreground),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: (job["skills"] as List<String>).map((skill) => Chip(
//                     label: Text(
//                       skill,
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                     backgroundColor: Colors.grey[800],
//                     labelStyle: const TextStyle(color: Colors.white),
//                   )).toList(),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Posted: ${job["postedDate"]}",
//                       style: TextStyle(color: mutedForeground, fontSize: 12),
//                     ),
//                     if (job["deadline"] != null)
//                       Text(
//                         "Deadline: ${job["deadline"]}",
//                         style: TextStyle(color: mutedForeground, fontSize: 12),
//                       ),
//                     if (job["duration"] != null)
//                       Text(
//                         "Duration: ${job["duration"]}",
//                         style: TextStyle(color: mutedForeground, fontSize: 12),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildReviewsTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent, Color primary) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SegmentedButton<String>(
//             segments: const [
//               ButtonSegment(value: 'All', label: Text('All')),
//               ButtonSegment(value: 'Cafe', label: Text('Cafe')),
//               ButtonSegment(value: 'Teacher', label: Text('Teacher')),
//             ],
//             selected: {_selectedReviewFilter},
//             onSelectionChanged: (Set<String> newSelection) {
//               setState(() {
//                 _selectedReviewFilter = newSelection.first;
//               });
//             },
//             style: ButtonStyle(
//               backgroundColor: WidgetStateProperty.resolveWith<Color>(
//                 (Set<WidgetState> states) {
//                   if (states.contains(WidgetState.selected)) {
//                     return primary;
//                   }
//                   return accent;
//                 },
//               ),
//               foregroundColor: WidgetStateProperty.resolveWith<Color>(
//                 (Set<WidgetState> states) {
//                   if (states.contains(WidgetState.selected)) {
//                     return Colors.white;
//                   }
//                   return foreground;
//                 },
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.all(8.0),
//             children: [
//               if (_selectedReviewFilter == 'All' || _selectedReviewFilter == 'Cafe')
//                 Stack(
//                   children: [
//                     // Third card (bottom)
//                     if (cafeReviews.length > 2)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 16.0),
//                         child: _buildCafeReviewCard(
//                           foodItem: cafeReviews[2]["foodItem"],
//                           cafeName: cafeReviews[2]["cafeName"],
//                           rating: cafeReviews[2]["rating"],
//                           review: cafeReviews[2]["review"],
//                           date: cafeReviews[2]["date"],
//                           foodItems: List<String>.from(cafeReviews[2]["foodItems"]),
//                           moreReviews: cafeReviews.length > 3 ? cafeReviews.length - 3 : null,
//                           background: background,
//                           foreground: foreground,
//                           border: border,
//                           mutedForeground: mutedForeground,
//                           accent: accent,
//                         ),
//                       ),
//                     // Second card (middle)
//                     if (cafeReviews.length > 1)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: _buildCafeReviewCard(
//                           foodItem: cafeReviews[1]["foodItem"],
//                           cafeName: cafeReviews[1]["cafeName"],
//                           rating: cafeReviews[1]["rating"],
//                           review: cafeReviews[1]["review"],
//                           date: cafeReviews[1]["date"],
//                           foodItems: List<String>.from(cafeReviews[1]["foodItems"]),
//                           background: background,
//                           foreground: foreground,
//                           border: border,
//                           mutedForeground: mutedForeground,
//                           accent: accent,
//                         ),
//                       ),
//                     // First card (top)
//                     if (cafeReviews.isNotEmpty)
//                       _buildCafeReviewCard(
//                         foodItem: cafeReviews[0]["foodItem"],
//                         cafeName: cafeReviews[0]["cafeName"],
//                         rating: cafeReviews[0]["rating"],
//                         review: cafeReviews[0]["review"],
//                         date: cafeReviews[0]["date"],
//                         foodItems: List<String>.from(cafeReviews[0]["foodItems"]),
//                         background: background,
//                         foreground: foreground,
//                         border: border,
//                         mutedForeground: mutedForeground,
//                         accent: accent,
//                       ),
//                   ],
//                 ),
//               if (_selectedReviewFilter == 'All' || _selectedReviewFilter == 'Teacher')
//                 _buildTeacherReviewCard(
//                   teacherName: "Prof. Smith",
//                   department: "Computer Science",
//                   rating: 5.0,
//                   review: "Excellent teaching methods and very helpful.",
//                   date: "2024-01-10",
//                   background: background,
//                   foreground: foreground,
//                   border: border,
//                   mutedForeground: mutedForeground,
//                   accent: accent,
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCafeReviewCard({
//     required String foodItem,
//     required String cafeName,
//     required double rating,
//     required String review,
//     required String date,
//     required List<String> foodItems,
//     int? moreReviews,
//     required Color background,
//     required Color foreground,
//     required Color border,
//     required Color mutedForeground,
//     required Color accent,
//   }) {
//     return Card(
//       color: accent,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: border),
//       ),
//       child: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           foodItem,
//                           style: TextStyle(
//                             color: foreground,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           cafeName,
//                           style: TextStyle(color: mutedForeground, fontSize: 14),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 20),
//                         Text(
//                           rating.toString(),
//                           style: TextStyle(color: foreground),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   review,
//                   style: TextStyle(color: mutedForeground),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: foodItems.map((item) => Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: background,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: border),
//                     ),
//                     child: Text(
//                       item,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: mutedForeground,
//                       ),
//                     ),
//                   )).toList(),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   date,
//                   style: TextStyle(color: mutedForeground, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           if (moreReviews != null)
//             Positioned(
//               bottom: 8,
//               right: 8,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: background,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: border),
//                 ),
//                 child: Text(
//                   '+$moreReviews more',
//                   style: TextStyle(
//                     color: mutedForeground,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTeacherReviewCard({
//     required String teacherName,
//     required String department,
//     required double rating,
//     required String review,
//     required String date,
//     required Color background,
//     required Color foreground,
//     required Color border,
//     required Color mutedForeground,
//     required Color accent,
//   }) {
//     return Card(
//       color: accent,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: border),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       teacherName,
//                       style: TextStyle(
//                         color: foreground,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       department,
//                       style: TextStyle(color: mutedForeground, fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber, size: 20),
//                     Text(
//                       rating.toString(),
//                       style: TextStyle(color: foreground),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               review,
//               style: TextStyle(color: mutedForeground),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               date,
//               style: TextStyle(color: mutedForeground, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authProvider);
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
//     // Custom theme colors
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
//     const primary = Color(0xFF8B5CF6);

//     return DefaultTabController(
//       length: 6,
//       child: Scaffold(
//         backgroundColor: background,
//         appBar: AppBar(
//           backgroundColor: background,
//           elevation: 0,
//           actions: [
//             IconButton(
//               icon: Icon(Icons.more_horiz, color: foreground),
//               onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
//             ),
//           ],
//         ),
//         body: NestedScrollView(
//           headerSliverBuilder: (context, innerBoxIsScrolled) {
//             return [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             auth.user?['name'] ?? "Logged Out",
//                             style: TextStyle(
//                               color: foreground,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: primary,
//                                 width: 2,
//                               ),
//                             ),
//                             child: CircleAvatar(
//                               radius: 30,
//                               backgroundColor: accent,
//                               backgroundImage: auth.user?['profile']['picture'] != null
//                                   ? NetworkImage(auth.user?['profile']['picture'])
//                                   : const AssetImage("assets/images/profilepic2.jpg")
//                                       as ImageProvider,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         "@${auth.user?['username'] ?? "Logged Out"}",
//                         style: TextStyle(color: mutedForeground, fontSize: 14),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Icon(Icons.calendar_today, color: mutedForeground, size: 16),
//                           const SizedBox(width: 8),
//                           Text(
//                             "Joined December 2023",
//                             style: TextStyle(color: mutedForeground),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: "10 ",
//                                   style: TextStyle(
//                                     color: foreground,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: "Following",
//                                   style: TextStyle(color: mutedForeground),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: "5 ",
//                                   style: TextStyle(
//                                     color: foreground,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: "Followers",
//                                   style: TextStyle(color: mutedForeground),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _SliverAppBarDelegate(
//                   TabBar(
//                     controller: _tabController,
//                     isScrollable: true,
//                     labelColor: foreground,
//                     unselectedLabelColor: mutedForeground,
//                     indicatorColor: primary,
//                     tabs: const [
//                       Tab(text: 'Posts'),
//                       Tab(text: 'Reposts'),
//                       Tab(text: 'Reviews'),
//                       Tab(text: 'Replies'),
//                       Tab(text: 'Society'),
//                       Tab(text: 'Jobs'),
//                     ],
//                   ),
//                   background,
//                 ),
//               ),
//             ];
//           },
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildPostsTab(background, foreground, border, mutedForeground, accent),
//               _buildRepostsTab(background, foreground, border, mutedForeground, accent),
//               _buildReviewsTab(background, foreground, border, mutedForeground, accent, primary),
//               Center(child: Text('Replies', style: TextStyle(color: foreground))),
//               _buildSocietyTab(background, foreground, border, mutedForeground, accent, primary),
//               _buildJobsTab(background, foreground, border, mutedForeground, accent, primary),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;
//   final Color _background;

//   _SliverAppBarDelegate(this._tabBar, this._background);

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: _background,
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }







import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/home/widgets/campus/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId; // Optional userId for viewing other profiles

  const ProfilePage({super.key, this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiClient = ApiClient();

  Map<String, dynamic>? _userProfile;
  List<dynamic> _posts = [];
  List<dynamic> _societies = [];
  List<dynamic> _connections = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize TabController based on isOwnProfile
    final auth = ref.read(authProvider);
    final isOwnProfile = widget.userId == null || widget.userId == auth.user?['_id'];
    _tabController = TabController(length: isOwnProfile ? 3 : 2, vsync: this);
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authProvider);
      final userId = widget.userId ?? auth.user?['_id'];
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      // Fetch user profile
      final profileResponse = await _apiClient.get('/api/user/profile', queryParameters: {'id': userId});
      // Check for error in response body (e.g., {"error": "User not found"})
      if (profileResponse.containsKey('error') || profileResponse['profile'] == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = profileResponse['error'] ?? 'User not found';
        });
        return;
      }
      final profileData = profileResponse as Map<String, dynamic>;
      final posts = profileData['profile']['posts'] ?? [];

      // Fetch societies
      final societiesResponse = await _apiClient.get('/api/user/subscribedSocieties', queryParameters: {'id': userId});
      final societiesData = societiesResponse['joinedSocieties'] ?? [];

      // Fetch connections
      final connectionsResponse = await _apiClient.get('/api/user/connections', queryParameters: {'id': userId});
      final connectionsData = connectionsResponse['connections'] ?? [];

      setState(() {
        _userProfile = profileData;
        _posts = posts.where((post) => post['author']['_id'] == userId).toList();
        _societies = societiesData;
        _connections = connectionsData;
        _isLoading = false;
      });
      debugPrint('Posts fetched: ${_posts.length}');
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile data: $e';
      });
    }
  }

  Future<void> _sendConnectRequest(String toUserId) async {
    try {
      await _apiClient.post('/api/user/add-friend', {'toFriendUser': toUserId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection request sent')),
      );
    } catch (e) {
      debugPrint('Error sending connection request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send connection request')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPostsTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent) {
    if (_posts.isEmpty) {
      return Center(child: Text('No posts yet', style: TextStyle(color: mutedForeground)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        debugPrint('Post $index media: ${post['media']}');
        debugPrint('Post $index media type: ${post['media']?.runtimeType}');
        return PostCard(post: post);
      },
    );
  }

  Widget _buildSocietyTab(Color background, Color foreground, Color border, Color mutedForeground, Color accent, Color primary) {
    if (_societies.isEmpty) {
      return Center(child: Text('No societies joined', style: TextStyle(color: mutedForeground)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _societies.length,
      itemBuilder: (context, index) {
        final society = _societies[index];
        return Card(
          color: accent,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      society["name"],
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '250 members', // Assume static or fetch from society details
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A community for enthusiasts.', // Assume static or fetch description
                  style: TextStyle(color: mutedForeground),
                ),
                const SizedBox(height: 16),
                Text(
                  'Activities:',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Events', 'Workshops'].map((activity) => Chip(
                    label: Text(
                      activity,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[800],
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Benefits:',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Networking', 'Skills'].map((benefit) => Chip(
                    label: Text(
                      benefit,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green[900],
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle join/leave society
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('View Society'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockedTab(Color background, Color foreground, Color mutedForeground) {
    return Center(
      child: Text(
        'No blocked users',
        style: TextStyle(color: mutedForeground, fontSize: 16),
      ),
    );
  }

  Widget _buildConnectButton(String userId, Color primary, Color foreground) {
    return ElevatedButton(
      onPressed: () => _sendConnectRequest(userId),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text('Connect'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    const primary = Color(0xFF8B5CF6);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: mutedForeground),
          ),
        ),
      );
    }

    final isOwnProfile = widget.userId == null || widget.userId == auth.user?['_id'];
    debugPrint('isOwnProfile: $isOwnProfile, TabController length: ${_tabController.length}');

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: Icon(Icons.more_horiz, color: foreground),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userProfile?['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '@${_userProfile?['username'] ?? 'unknown'}',
                                style: TextStyle(color: mutedForeground, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: accent,
                            backgroundImage: _userProfile?['profile']['picture'] != null
                                ? NetworkImage(_userProfile!['profile']['picture'])
                                : const AssetImage("assets/images/profilepic2.jpg") as ImageProvider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: mutedForeground, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Joined ${_userProfile?['joined'] ?? 'Unknown'}',
                          style: TextStyle(color: mutedForeground),
                        ),
                      ],
                    ),
                    if (_userProfile?['profile']['bio']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      Text(
                        _userProfile!['profile']['bio'],
                        style: TextStyle(color: mutedForeground),
                      ),
                    ],
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_connections.length} ',
                            style: TextStyle(
                              color: foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: 'Connections',
                            style: TextStyle(color: mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    if (!isOwnProfile) ...[
                      const SizedBox(height: 16),
                      _buildConnectButton(_userProfile!['_id'], primary, foreground),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: foreground,
                  unselectedLabelColor: mutedForeground,
                  indicatorColor: primary,
                  tabs: [
                    const Tab(text: 'Posts'),
                    const Tab(text: 'Society'),
                    if (isOwnProfile) const Tab(text: 'Blocked'),
                  ],
                ),
                background,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(background, foreground, border, mutedForeground, accent),
            _buildSocietyTab(background, foreground, border, mutedForeground, accent, primary),
            if (isOwnProfile)
              _buildBlockedTab(background, foreground, mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _background;

  _SliverAppBarDelegate(this._tabBar, this._background);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}