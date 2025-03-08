// import 'package:flutter/material.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import '../../widgets/gif_picker.dart';

// class CommentDetailsPage extends StatefulWidget {
//   final Map<String, dynamic> comment;
//   final String teacherId;
//   final bool isDark;

//   const CommentDetailsPage({
//     super.key,
//     required this.comment,
//     required this.teacherId,
//     required this.isDark,
//   });

//   @override
//   State<CommentDetailsPage> createState() => _CommentDetailsPageState();
// }

// class _CommentDetailsPageState extends State<CommentDetailsPage> {
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _replies = [];
//   bool _isNestedView = true;
//   final Map<String, bool> _showNestedReplies = {};
//   final Map<String, List<Map<String, dynamic>>> _nestedRepliesCache = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchReplies();
//   }

//   Future<void> _fetchReplies() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final ApiClient apiClient = ApiClient();
//       final response = await apiClient.get(
//         '/api/teacher/reply/feedback',
//         queryParameters: {'feedbackCommentId': widget.comment['_id']},
//       );

//       setState(() {
//         _replies = List<Map<String, dynamic>>.from(response['replies']['replies'] ?? []);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to load replies: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Add vote functionality
//   Future<void> _handleVote(String commentId, bool isUpvote) async {
//     try {
//       final ApiClient apiClient = ApiClient();
//       await apiClient.post(
//         '/api/teacher/feedback/vote',
//         {
//           'feedbackId': commentId,
//           'voteType': isUpvote ? 'upvote' : 'downvote',
//         },
//       );
//       _fetchReplies();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to vote: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Add reaction functionality
//   Future<void> _handleReaction(String replyId, String reactionType) async {
//     try {
//       final ApiClient apiClient = ApiClient();
//       await apiClient.post(
//         '/api/teacher/reply/react',
//         {
//           'replyId': replyId,
//           'reactionType': reactionType,
//         },
//       );
//       _fetchReplies();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to react: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Add optimistic reply handling
//   void _addReplyOptimistically(Map<String, dynamic> reply, String parentId, bool isReplyToReply) {
//     setState(() {
//       if (!isReplyToReply) {
//         // Add to root replies
//         _replies.add(reply);
//       } else {
//         // Add to nested replies cache
//         final nestedReplies = _nestedRepliesCache[parentId] ?? [];
//         nestedReplies.add(reply);
//         _nestedRepliesCache[parentId] = nestedReplies;
//         // Ensure the replies are shown
//         _showNestedReplies[parentId] = true;
//       }
//     });
//   }

//   // Remove optimistic reply if API call fails
//   void _removeOptimisticReply(String tempId, String parentId, bool isReplyToReply) {
//     setState(() {
//       if (!isReplyToReply) {
//         _replies.removeWhere((r) => r['_id'] == tempId);
//       } else {
//         final nestedReplies = _nestedRepliesCache[parentId] ?? [];
//         nestedReplies.removeWhere((r) => r['_id'] == tempId);
//         _nestedRepliesCache[parentId] = nestedReplies;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: widget.isDark ? Colors.black : Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Comment Details'),
//         backgroundColor: widget.isDark ? Colors.black : Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isNestedView ? Icons.account_tree_outlined : Icons.format_list_bulleted,
//               color: widget.isDark ? Colors.white : Colors.black,
//             ),
//             tooltip: _isNestedView ? 'Switch to Flat View' : 'Switch to Nested View',
//             onPressed: () {
//               setState(() {
//                 _isNestedView = !_isNestedView;
//               });
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           // Original Comment
//           Container(
//             margin: const EdgeInsets.only(bottom: 1),
//             color: widget.isDark ? Colors.black : Colors.white,
//             child: _buildOriginalComment(),
//           ),

//           // Replies Section
//           Container(
//             color: widget.isDark ? Colors.black : Colors.white,
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Replies',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (_isLoading)
//                   const Center(child: CircularProgressIndicator())
//                 else if (_replies.isEmpty)
//                   Center(
//                     child: Text(
//                       'No replies yet',
//                       style: theme.textTheme.bodyLarge?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   )
//                 else
//                   Column(
//                     children: _isNestedView 
//                       ? _replies.map((reply) => _buildReplyItem(reply)).toList()
//                       : _buildFlatReplies(_replies),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOriginalComment() {
//     final theme = Theme.of(context);
//     final user = widget.comment['user'];
//     final name = user['name'] ?? 'Anonymous';
//     final isDeleted = user['_id'] == null;
//     final isAnonymous = widget.comment['isAnonymous'] ?? false;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
//                 child: Text(
//                   name[0].toUpperCase(),
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: widget.isDark ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               isAnonymous ? 'Anonymous' : name,
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
//                               ),
//                             ),
//                             if (!isDeleted && !isAnonymous && user['isVerified'] == true) ...[
//                               const SizedBox(width: 4),
//                               const Icon(
//                                 Icons.verified_rounded,
//                                 size: 16,
//                                 color: Colors.blue,
//                               ),
//                             ],
//                           ],
//                         ),
//                         // Rating Stars
//                         if (widget.comment['rating'] != null)
//                           Row(
//                             children: List.generate(5, (index) {
//                               return Icon(
//                                 index < (widget.comment['rating'] as int)
//                                     ? Icons.star_rounded
//                                     : Icons.star_outline_rounded,
//                                 size: 16,
//                                 color: index < (widget.comment['rating'] as int)
//                                     ? const Color(0xFFFFD700)
//                                     : widget.isDark 
//                                         ? Colors.white.withOpacity(0.3)
//                                         : Colors.black.withOpacity(0.3),
//                               );
//                             }),
//                           ),
//                       ],
//                     ),
//                     Text(
//                       widget.comment['updatedAt'] != null 
//                         ? _formatDate(widget.comment['updatedAt'])
//                         : '',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.5),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.only(left: 44),
//             child: Text(
//               widget.comment['feedback'] ?? '',
//               style: theme.textTheme.bodyMedium,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.only(left: 44),
//             child: Row(
//               children: [
//                 _VoteButton(
//                   icon: Icons.arrow_upward_rounded,
//                   count: widget.comment['upvoteCount'] ?? 0,
//                   isDark: widget.isDark,
//                   onPressed: () => _handleVote(widget.comment['_id'], true),
//                 ),
//                 const SizedBox(width: 16),
//                 _VoteButton(
//                   icon: Icons.arrow_downward_rounded,
//                   count: widget.comment['downvoteCount'] ?? 0,
//                   isDark: widget.isDark,
//                   onPressed: () => _handleVote(widget.comment['_id'], false),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.only(left: 44),
//             child: _buildReplyBox(widget.comment['_id']),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReplyItem(Map<String, dynamic> reply) {
//     final theme = Theme.of(context);
//     final user = reply['user'] ?? {};
//     final name = user['name'] ?? '[deleted]';
//     final isDeleted = user['_id'] == null;
//     final isAnonymous = reply['isAnonymous'] ?? false;
//     final date = reply['updatedAt'] ?? reply['createdAt'] ?? '';
//     final replyText = reply['comment'] ?? reply['text'] ?? '';
//     final gifUrl = reply['gifUrl'];
//     final reactions = reply['reactions'] as Map<String, dynamic>? ?? {};

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           left: BorderSide(
//             color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
//             width: 2,
//           ),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 12,
//                   backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
//                   child: Text(
//                     (isAnonymous ? 'A' : name[0]).toUpperCase(),
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: widget.isDark ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Text(
//                         isAnonymous ? 'Anonymous' : name,
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
//                         ),
//                       ),
//                       if (!isDeleted && !isAnonymous && user['isVerified'] == true) ...[
//                         const SizedBox(width: 4),
//                         const Icon(
//                           Icons.verified_rounded,
//                           size: 14,
//                           color: Colors.blue,
//                         ),
//                       ],
//                       const Spacer(),
//                       Text(
//                         _formatDate(date),
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: theme.colorScheme.onSurface.withOpacity(0.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               replyText,
//               style: theme.textTheme.bodyMedium,
//             ),
//             if (gifUrl != null && gifUrl.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   gifUrl,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//             const SizedBox(height: 8),
//             // Reactions row
//             Row(
//               children: [
//                 Wrap(
//                   spacing: 8,
//                   children: [
//                     for (final reaction in [
//                       {'emoji': '😄', 'type': 'haha'},
//                       {'emoji': '😢', 'type': 'sad'},
//                       {'emoji': '❤️', 'type': 'love'},
//                       {'emoji': '😠', 'type': 'angry'},
//                       {'emoji': '💡', 'type': 'insightful'},
//                     ])
//                       _ReactionButton(
//                         emoji: reaction['emoji'] as String,
//                         count: reactions[reaction['type']] ?? 0,
//                         isDark: widget.isDark,
//                         isSelected: false,
//                         onPressed: () => _handleReaction(reply['_id'], reaction['type'] as String),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             _buildReplyBox(reply['_id'], isReplyToReply: true),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReplyBox(String parentId, {bool isReplyToReply = false}) {
//     final theme = Theme.of(context);
//     final replyController = TextEditingController();
//     bool showGifPicker = false;
//     String? selectedGifUrl;

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Container(
//           decoration: BoxDecoration(
//             color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
//             ),
//           ),
//           child: Column(
//             children: [
//               if (selectedGifUrl != null) ...[
//                 Stack(
//                   children: [
//                     Image.network(
//                       selectedGifUrl!,
//                       height: 150,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: IconButton(
//                         onPressed: () {
//                           setState(() {
//                             selectedGifUrl = null;
//                           });
//                         },
//                         icon: const Icon(Icons.close),
//                         style: IconButton.styleFrom(
//                           backgroundColor: Colors.black54,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       setState(() {
//                         showGifPicker = !showGifPicker;
//                       });
//                     },
//                     icon: const Icon(Icons.gif_box_outlined),
//                     color: widget.isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: replyController,
//                       style: theme.textTheme.bodyMedium,
//                       decoration: InputDecoration(
//                         hintText: 'Write a reply...',
//                         hintStyle: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onSurface.withOpacity(0.5),
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.all(12),
//                       ),
//                     ),
//                   ),
//                   Consumer(
//                     builder: (context, ref, _) => TextButton(
//                       onPressed: () async {
//                         final text = replyController.text.trim();
//                         if (text.isEmpty) return;

//                         try {
//                           final userMap = ref.read(authProvider).user;
//                           if (userMap == null) {
//                             throw Exception('User not authenticated');
//                           }

//                           final tempId = DateTime.now().toIso8601String();
//                           // Create optimistic reply
//                           final optimisticReply = {
//                             '_id': tempId,
//                             'comment': text,
//                             'gifUrl': selectedGifUrl,
//                             'user': {
//                               '_id': userMap['_id'],
//                               'name': userMap['name'],
//                               'isVerified': userMap['isVerified'],
//                             },
//                             'isAnonymous': false,
//                             'createdAt': DateTime.now().toIso8601String(),
//                             'reactions': {},
//                           };

//                           // Add reply optimistically
//                           _addReplyOptimistically(optimisticReply, parentId, isReplyToReply);

//                           // Clear input
//                           replyController.clear();
//                           setState(() {
//                             selectedGifUrl = null;
//                             showGifPicker = false;
//                           });

//                           final ApiClient apiClient = ApiClient();
//                           final endpoint = isReplyToReply 
//                             ? '/api/teacher/reply/reply/feedback'
//                             : '/api/teacher/reply/feedback';

//                           final response = await apiClient.post(
//                             endpoint,
//                             {
//                               'teacherId': widget.teacherId,
//                               isReplyToReply ? 'feedbackCommentId' : 'feedbackReviewId': parentId,
//                               'feedbackComment': text,
//                               'gifUrl': selectedGifUrl ?? '',
//                             },
//                           );

//                           // Update the optimistic reply with the real data
//                           setState(() {
//                             if (!isReplyToReply) {
//                               final index = _replies.indexWhere((r) => r['_id'] == tempId);
//                               if (index != -1) {
//                                 _replies[index] = response['reply'];
//                               }
//                             } else {
//                               final nestedReplies = _nestedRepliesCache[parentId] ?? [];
//                               final index = nestedReplies.indexWhere((r) => r['_id'] == tempId);
//                               if (index != -1) {
//                                 nestedReplies[index] = response['reply'];
//                                 _nestedRepliesCache[parentId] = nestedReplies;
//                               }
//                             }
//                           });

//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Reply posted successfully'),
//                                 backgroundColor: Colors.green,
//                                 duration: Duration(seconds: 2),
//                               ),
//                             );
//                           }
//                         } catch (e) {
//                           // Remove optimistic reply on error
//                           _removeOptimisticReply("tempId", parentId, isReplyToReply);

//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Failed to post reply: ${e.toString()}'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                           }
//                         }
//                       },
//                       style: TextButton.styleFrom(
//                         backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(11),
//                             bottomRight: Radius.circular(11),
//                           ),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                       child: Text(
//                         'Reply',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: widget.isDark ? Colors.white : Colors.white,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (showGifPicker)
//                 Container(
//                   height: 300,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                         color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
//                       ),
//                     ),
//                   ),
//                   child: GifPicker(
//                     isDark: widget.isDark,
//                     onGifSelected: (gifUrl) {
//                       setState(() {
//                         selectedGifUrl = gifUrl;
//                         showGifPicker = false;
//                       });
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> _buildFlatReplies(List<Map<String, dynamic>> replies) {
//     return replies.map((reply) => Padding(
//       padding: const EdgeInsets.only(left: 24.0),
//       child: _buildFlatReplyItem(reply),
//     )).toList();
//   }

//   Widget _buildFlatReplyItem(Map<String, dynamic> reply) {
//     final theme = Theme.of(context);
//     final user = reply['user'] ?? {};
//     final name = user['name'] ?? '[deleted]';
//     final isDeleted = user['_id'] == null;
//     final isAnonymous = reply['isAnonymous'] ?? false;
//     final date = reply['updatedAt'] ?? reply['createdAt'] ?? '';
//     final replyText = reply['comment'] ?? reply['text'] ?? '';
//     final gifUrl = reply['gifUrl'];
//     final reactions = reply['reactions'] as Map<String, dynamic>? ?? {};

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           left: BorderSide(
//             color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
//             width: 2,
//           ),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 12,
//                   backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
//                   child: Text(
//                     (isAnonymous ? 'A' : name[0]).toUpperCase(),
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: widget.isDark ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Text(
//                         isAnonymous ? 'Anonymous' : name,
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
//                         ),
//                       ),
//                       if (!isDeleted && !isAnonymous && user['isVerified'] == true) ...[
//                         const SizedBox(width: 4),
//                         const Icon(
//                           Icons.verified_rounded,
//                           size: 14,
//                           color: Colors.blue,
//                         ),
//                       ],
//                       const Spacer(),
//                       Text(
//                         _formatDate(date),
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: theme.colorScheme.onSurface.withOpacity(0.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               replyText,
//               style: theme.textTheme.bodyMedium,
//             ),
//             if (gifUrl != null && gifUrl.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   gifUrl,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ],
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Wrap(
//                   spacing: 8,
//                   children: [
//                     for (final reaction in [
//                       {'emoji': '😄', 'type': 'haha'},
//                       {'emoji': '😢', 'type': 'sad'},
//                       {'emoji': '❤️', 'type': 'love'},
//                       {'emoji': '😠', 'type': 'angry'},
//                       {'emoji': '💡', 'type': 'insightful'},
//                     ])
//                       _ReactionButton(
//                         emoji: reaction['emoji'] as String,
//                         count: reactions[reaction['type']] ?? 0,
//                         isDark: widget.isDark,
//                         isSelected: false,
//                         onPressed: () => _handleReaction(reply['_id'], reaction['type'] as String),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             _buildReplyBox(reply['_id'], isReplyToReply: true),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(String dateStr) {
//     if (dateStr.isEmpty) return '';
    
//     final date = DateTime.parse(dateStr);
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays > 365) {
//       return '${(difference.inDays / 365).floor()} years ago';
//     } else if (difference.inDays > 30) {
//       return '${(difference.inDays / 30).floor()} months ago';
//     } else if (difference.inDays > 0) {
//       return '${difference.inDays} days ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hours ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} minutes ago';
//     } else {
//       return 'Just now';
//     }
//   }

//   // Add VoteButton widget
//   Widget _VoteButton({
//     required IconData icon,
//     required int count,
//     required bool isDark,
//     required VoidCallback onPressed,
//   }) {
//     final theme = Theme.of(context);

//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
//             ),
//             const SizedBox(width: 4),
//             Text(
//               count.toString(),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.w500,
//                 color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Add ReactionButton widget
//   Widget _ReactionButton({
//     required String emoji,
//     required int count,
//     required bool isDark,
//     required bool isSelected,
//     required VoidCallback onPressed,
//   }) {
//     final theme = Theme.of(context);

//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))
//               : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
//           borderRadius: BorderRadius.circular(8),
//           border: isSelected
//               ? Border.all(
//                   color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
//                 )
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(emoji, style: const TextStyle(fontSize: 16)),
//             if (count > 0) ...[
//               const SizedBox(width: 4),
//               Text(
//                 count.toString(),
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// } 