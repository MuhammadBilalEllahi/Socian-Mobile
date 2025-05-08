// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../service/AllUniversityService.dart';

// class CommentItem extends StatefulWidget {
//   final Map<String, dynamic> comment;
//   final bool isCurrentUser;
//   final Function(String) onReply;
//   final Function(String) onEdit;
//   final Function(String) onDelete;

//   const CommentItem({
//     super.key,
//     required this.comment,
//     required this.isCurrentUser,
//     required this.onReply,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   State<CommentItem> createState() => _CommentItemState();
// }

// class _CommentItemState extends State<CommentItem> {
//   bool _showReplies = false;
//   bool _isLiked = false;
//   bool _isDisliked = false;
//   final bool _showOptions = false;

//   @override
//   void initState() {
//     super.initState();
//     _isLiked = widget.comment['voteId']?['userVotes']?['upvote'] ?? false;
//     _isDisliked = widget.comment['voteId']?['userVotes']?['downvote'] ?? false;
//   }

//   void _handleVote(String voteType) async {
//     try {
//       await AllUniversityService.voteComment(widget.comment['_id'], voteType);
//       setState(() {
//         if (voteType == 'upvote') {
//           _isLiked = !_isLiked;
//           if (_isLiked) _isDisliked = false;
//         } else if (voteType == 'downvote') {
//           _isDisliked = !_isDisliked;
//           if (_isDisliked) _isLiked = false;
//         }
//       });
//     } catch (e) {
//       debugPrint('Error voting comment: $e');
//     }
//   }

//   void _showReportDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Report Comment'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.report_problem),
//               title: const Text('Spam'),
//               onTap: () {
//                 // TODO: Implement spam report
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.warning),
//               title: const Text('Harassment'),
//               onTap: () {
//                 // TODO: Implement harassment report
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.block),
//               title: const Text('Inappropriate Content'),
//               onTap: () {
//                 // TODO: Implement inappropriate content report
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showOptionsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Comment Options'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.isCurrentUser) ...[
//               ListTile(
//                 leading: const Icon(Icons.edit),
//                 title: const Text('Edit'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onEdit(widget.comment['_id']);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.delete),
//                 title: const Text('Delete'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   widget.onDelete(widget.comment['_id']);
//                 },
//               ),
//             ],
//             ListTile(
//               leading: const Icon(Icons.flag),
//               title: const Text('Report'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showReportDialog();
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final formattedDate = DateFormat('MMM d, y').format(DateTime.parse(widget.comment['createdAt']));
//     final replies = widget.comment['replies'] as List<dynamic>?;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundImage: widget.comment['author'] != null && 
//                     widget.comment['author']['profile'] != null
//                     ? NetworkImage(widget.comment['author']['profile']['picture'] ?? '')
//                     : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           widget.comment['author']?['name'] ?? '{Deleted}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           '@${widget.comment['author']?['username'] ?? ''}',
//                           style: TextStyle(
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           formattedDate,
//                           style: TextStyle(
//                             color: isDark ? Colors.grey[400] : Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                         const Spacer(),
//                         IconButton(
//                           icon: const Icon(Icons.more_vert, size: 20),
//                           onPressed: _showOptionsDialog,
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       widget.comment['comment'],
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         _buildActionButton(
//                           icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
//                           count: widget.comment['voteId']?['upVotesCount'] ?? 0,
//                           isActive: _isLiked,
//                           onTap: () => _handleVote('upvote'),
//                         ),
//                         const SizedBox(width: 16),
//                         _buildActionButton(
//                           icon: _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
//                           count: widget.comment['voteId']?['downVotesCount'] ?? 0,
//                           isActive: _isDisliked,
//                           onTap: () => _handleVote('downvote'),
//                         ),
//                         const SizedBox(width: 16),
//                         _buildActionButton(
//                           icon: Icons.reply_outlined,
//                           count: widget.comment['repliesCount'] ?? 0,
//                           isActive: false,
//                           onTap: () => widget.onReply(widget.comment['_id']),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (_showReplies && replies != null && replies.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(left: 48),
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: replies.length,
//               itemBuilder: (context, index) {
//                 final reply = replies[index];
//                 return CommentItem(
//                   comment: reply,
//                   isCurrentUser: false, // TODO: Check if reply is from current user
//                   onReply: widget.onReply,
//                   onEdit: widget.onEdit,
//                   onDelete: widget.onDelete,
//                 );
//               },
//             ),
//           ),
//         if ((widget.comment['repliesCount'] ?? 0) > 0)
//           Padding(
//             padding: const EdgeInsets.only(left: 48),
//             child: TextButton(
//               onPressed: () {
//                 setState(() {
//                   _showReplies = !_showReplies;
//                 });
//               },
//               child: Text(
//                 _showReplies ? 'Hide Replies' : 'Show ${widget.comment['repliesCount']} Replies',
//                 style: TextStyle(
//                   color: isDark ? Colors.blue[300] : Colors.blue,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required int count,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: isActive ? Colors.blue : Colors.grey,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             count > 0 ? count.toString() : '',
//             style: TextStyle(
//               fontSize: 12,
//               color: isActive ? Colors.blue : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 