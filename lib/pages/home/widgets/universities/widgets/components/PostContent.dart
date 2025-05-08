// import 'package:flutter/material.dart';

// class PostContent extends StatelessWidget {
//   final String? title;
//   final String? body;

//   const PostContent({
//     super.key,
//     required this.title,
//     required this.body,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (title != null && title!.isNotEmpty) ...[
//           Text(
//             title!,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: isDark ? Colors.white : Colors.black,
//               height: 1.2,
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//         if (body != null && body!.isNotEmpty)
//           Text(
//             body!,
//             style: TextStyle(
//               fontSize: 14,
//               height: 1.4,
//               color: isDark ? Colors.white : Colors.black,
//             ),
//           ),
//       ],
//     );
//   }
// }
