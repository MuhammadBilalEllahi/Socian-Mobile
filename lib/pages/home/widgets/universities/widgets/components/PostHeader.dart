// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PostHeader extends StatelessWidget {
//   final Map<String, dynamic>? author;
//   final String createdAt;

//   const PostHeader({
//     super.key,
//     required this.author,
//     required this.createdAt,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final formattedDate = DateFormat('MMM d, y').format(DateTime.parse(createdAt));

//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 18,
//           backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
//           backgroundImage: author != null && author!['profile'] != null
//               ? NetworkImage(author!['profile']['picture'] ?? '')
//               : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 author?['name'] ?? '{Deleted}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 12,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 1),
//               Row(
//                 children: [
//                   Text(
//                     '@${author?['username'] ?? ''}',
//                     style: TextStyle(
//                       color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       fontSize: 10,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     width: 4,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     formattedDate,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: isDark ? Colors.grey[400] : Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
