// import 'package:flutter/material.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'CommentItem.dart';
// import '../../service/AllUniversityService.dart';

// class CommentsBottomSheet extends StatefulWidget {
//   final String postId;

//   const CommentsBottomSheet({
//     super.key,
//     required this.postId,
//   });

//   @override
//   State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
// }

// class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
//   final TextEditingController _commentController = TextEditingController();
//   final TextEditingController _replyController = TextEditingController();
//   List<Map<String, dynamic>> _comments = [];
//   bool _isLoading = true;
//   String? _replyingTo;
//   String? _editingCommentId;

//   @override
//   void initState() {
//     super.initState();
//     _loadComments();
//   }

//   Future<void> _loadComments() async {
//     try {
//       final response = await AllUniversityService.getComments(widget.postId);
//       debugPrint('Comments--------------: $response');
//       setState(() {
//         _comments = List<Map<String, dynamic>>.from(response);
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading comments: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _submitComment() async {
//     if (_commentController.text.trim().isEmpty) return;

//     try {
//       final response = await AllUniversityService.createComment(
//         widget.postId,
//         _commentController.text.trim(),
//       );
//       setState(() {
//         _comments.insert(0, response);
//         _commentController.clear();
//       });
//     } catch (e) {
//       debugPrint('Error submitting comment: $e');
//     }
//   }

//   Future<void> _submitReply(String commentId) async {
//     if (_replyController.text.trim().isEmpty) return;

//     try {
//       final response = await AllUniversityService.replyToComment(
//         widget.postId,
//         commentId,
//         _replyController.text.trim(),
//       );
//       setState(() {
//         final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
//         if (commentIndex != -1) {
//           _comments[commentIndex]['replies'] ??= [];
//           _comments[commentIndex]['replies'].insert(0, response);
//           _comments[commentIndex]['repliesCount'] = 
//               (_comments[commentIndex]['repliesCount'] ?? 0) + 1;
//         }
//         _replyController.clear();
//         _replyingTo = null;
//       });
//     } catch (e) {
//       debugPrint('Error submitting reply: $e');
//     }
//   }

//   Future<void> _editComment(String commentId) async {
//     if (_commentController.text.trim().isEmpty) return;

//     try {
//       final response = await AllUniversityService.updateComment(
//         commentId,
//         _commentController.text.trim(),
//       );
//       setState(() {
//         final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
//         if (commentIndex != -1) {
//           _comments[commentIndex] = response;
//         }
//         _commentController.clear();
//         _editingCommentId = null;
//       });
//     } catch (e) {
//       debugPrint('Error editing comment: $e');
//     }
//   }

//   Future<void> _deleteComment(String commentId) async {
//     try {
//       await AllUniversityService.deleteComment(commentId);
//       setState(() {
//         _comments.removeWhere((c) => c['_id'] == commentId);
//       });
//     } catch (e) {
//       debugPrint('Error deleting comment: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     _replyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDark ? const Color(0xFF09090B) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black;
//     final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E5E5);
//     final inputBackgroundColor = isDark ? const Color(0xFF18181B) : Colors.white;
    
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Padding(
//             padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E5E5),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
          
//           // Header
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Row(
//               children: [
//                 Text(
//                   'Comments',
//                   style: TextStyle(
//                     color: textColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: Icon(
//                     Icons.close,
//                     color: textColor.withOpacity(0.7),
//                     size: 20,
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
          
//           Divider(
//             height: 1,
//             thickness: 1,
//             color: borderColor,
//           ),
          
//           // Comments list
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     itemCount: _comments.length,
//                     itemBuilder: (context, index) {
//                       final comment = _comments[index];
//                       return CommentItem(
//                         comment: comment,
//                         isCurrentUser: false, // TODO: Check if comment is from current user
//                         onReply: (commentId) {
//                           setState(() {
//                             _replyingTo = commentId;
//                             _editingCommentId = null;
//                           });
//                         },
//                         onEdit: (commentId) {
//                           setState(() {
//                             _editingCommentId = commentId;
//                             _commentController.text = comment['comment'];
//                             _replyingTo = null;
//                           });
//                         },
//                         onDelete: _deleteComment,
//                       );
//                     },
//                   ),
//           ),
          
//           // Comment input
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: backgroundColor,
//               border: Border(
//                 top: BorderSide(
//                   color: borderColor,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Column(
//               children: [
//                 if (_replyingTo != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Text(
//                           'Replying to a comment',
//                           style: TextStyle(
//                             color: textColor.withOpacity(0.7),
//                             fontSize: 12,
//                           ),
//                         ),
//                         const Spacer(),
//                         IconButton(
//                           icon: Icon(
//                             Icons.close,
//                             color: textColor.withOpacity(0.7),
//                             size: 16,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _replyingTo = null;
//                               _replyController.clear();
//                             });
//                           },
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: inputBackgroundColor,
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(
//                             color: borderColor,
//                             width: 1,
//                           ),
//                         ),
//                         child: TextField(
//                           controller: _replyingTo != null ? _replyController : _commentController,
//                           style: TextStyle(
//                             color: textColor,
//                             fontSize: 14,
//                           ),
//                           maxLines: 4,
//                           minLines: 1,
//                           decoration: InputDecoration(
//                             isDense: true,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 10,
//                             ),
//                             hintText: _replyingTo != null ? 'Write a reply...' : 'Write a comment...',
//                             hintStyle: TextStyle(
//                               color: textColor.withOpacity(0.5),
//                               fontSize: 14,
//                             ),
//                             border: InputBorder.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       height: 36,
//                       width: 36,
//                       decoration: BoxDecoration(
//                         color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.send_rounded,
//                           color: textColor,
//                           size: 16,
//                         ),
//                         padding: EdgeInsets.zero,
//                         onPressed: () {
//                           if (_replyingTo != null) {
//                             _submitReply(_replyingTo!);
//                           } else if (_editingCommentId != null) {
//                             _editComment(_editingCommentId!);
//                           } else {
//                             _submitComment();
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }