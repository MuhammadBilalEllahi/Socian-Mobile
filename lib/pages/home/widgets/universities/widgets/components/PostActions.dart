// import 'package:flutter/material.dart';

// class PostActions extends StatelessWidget {
//   final int upvotes;
//   final int downvotes;
//   final int commentsCount;
//   final bool isLiked;
//   final bool isDisliked;
//   final Function(String) onVote;
//   final VoidCallback onComment;

//   const PostActions({
//     super.key,
//     required this.upvotes,
//     required this.downvotes,
//     required this.commentsCount,
//     required this.isLiked,
//     required this.isDisliked,
//     required this.onVote,
//     required this.onComment,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         _buildActionButton(
//           context,
//           icon: Icons.favorite_outline,
//           count: upvotes,
//           isActive: isLiked,
//           onTap: () => onVote('upvote'),
//         ),
//         _buildActionButton(
//           context,
//           icon: Icons.thumb_down_outlined,
//           count: downvotes,
//           isActive: isDisliked,
//           onTap: () => onVote('downvote'),
//         ),
//         _buildActionButton(
//           context,
//           icon: Icons.chat_bubble_outline,
//           count: commentsCount,
//           isActive: false,
//           onTap: onComment,
//         ),
//         _buildActionButton(
//           context,
//           icon: Icons.repeat,
//           count: 0,
//           isActive: false,
//           onTap: () {
//             // TODO: Implement repost
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton(
//     BuildContext context, {
//     required IconData icon,
//     required int count,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: isActive ? Colors.red.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: isActive ? Colors.red : Colors.grey[600],
//             ),
//             const SizedBox(width: 4),
//             Text(
//               count > 0 ? count.toString() : '',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isActive ? Colors.red : Colors.grey[600],
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
