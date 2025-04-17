// import 'package:flutter/material.dart';

// class Comment extends StatelessWidget {
//   final String id;

//   const Comment({super.key, required this.id});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Past Papers'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(8.0),
//         children: const [
//           // Example comment section
//           CommentWidget(
//             comment: 'This is a great past paper!',
//             replies: [
//               'I agree, very helpful.',
//               'Thanks for sharing!',
//             ],
//           ),
//           CommentWidget(
//             comment: 'Does anyone have the answer key?',
//             replies: [
//               'I think it\'s in the back of the book.',
//               'You can find it online.',
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CommentWidget extends StatelessWidget {
//   final String comment;
//   final List<String> replies;

//   const CommentWidget({super.key, required this.comment, required this.replies});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               comment,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8.0),
//             ...replies.map((reply) => Padding(
//               padding: const EdgeInsets.only(left: 16.0, top: 4.0),
//               child: Text('- $reply'),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
