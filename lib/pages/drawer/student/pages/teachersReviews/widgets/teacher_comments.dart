import 'dart:async';
import 'dart:developer';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/drawer/student/pages/teachersReviews/pages/comment_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

import 'gif_picker.dart';

class TeacherComments extends StatefulWidget {
  final String teacherId;

  const TeacherComments({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherComments> createState() => TeacherCommentsState();
}

class TeacherCommentsState extends State<TeacherComments> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  int _rating = 0;
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Add optimistic comment support
  void addOptimisticComment(Map<String, dynamic> optimisticComment,
      {required Future<bool> Function() confirm}) async {
    final userId = optimisticComment['user']?['_id'];
    setState(() {
      // Remove any existing comment from the same user
      _comments = _comments.where((c) => c['user']?['_id'] != userId).toList();
      // Add the optimistic comment to the top
      _comments = [optimisticComment, ..._comments];
    });
    final index =
        _comments.indexWhere((c) => c['_id'] == optimisticComment['_id']);
    final success = await confirm();
    if (!mounted) return;
    if (success) {
      setState(() {
        if (index >= 0 && index < _comments.length) {
          _comments[index]['opacity'] = 1.0;
          _comments[index]['optimistic'] = false;
        }
      });
    } else {
      setState(() {
        _comments.removeWhere((c) => c['_id'] == optimisticComment['_id']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to post comment'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ApiClient apiClient = ApiClient();
      final response = await apiClient.get(
        '/api/teacher/mob/reviews/feedbacks',
        queryParameters: {'id': widget.teacherId},
      );

      log("comments response: $response");
      setState(() {
        _comments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load comments: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _submitComment(WidgetRef ref) async {
  //   if (_commentController.text.trim().isEmpty || _rating == 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please provide both a rating and a comment'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isSubmitting = true;
  //   });

  //   try {
  //     final user = ref.read(authProvider).user;
  //     if (user == null) {
  //       throw Exception('User not authenticated');
  //     }

  //     final ApiClient apiClient = ApiClient();

  //     debugPrint("rating: $_rating");
  //     debugPrint("comment: ${_commentController.text.trim()}");
  //     debugPrint("isAnonymous: $_isAnonymous");
  //     debugPrint("user: $user");
  //     debugPrint("teacherId: ${widget.teacherId}");
  //     debugPrint("userId: ${user['_id']}");

  //     await apiClient.post(
  //       '/api/teacher/rate',
  //       {
  //         'teacherId': widget.teacherId,
  //         'userId': user['_id'],
  //         'rating': _rating,
  //         'feedback': _commentController.text.trim(),
  //         'hideUser': _isAnonymous,
  //       },
  //     );

  //     // Clear form and show success message
  //     _commentController.clear();
  //     setState(() {
  //       _rating = 0;
  //       _isAnonymous = false;
  //     });

  //     // Fetch updated comments
  //     // await _fetchComments();

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Comment posted successfully'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to post comment: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isSubmitting = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Comments',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Comment Box
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 24),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       // color: Colors.yellow,
        //       color: Colors.transparent,
        //       // color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        //       borderRadius: BorderRadius.circular(16),
        //       border: Border.all(
        //         color: isDark
        //             ? Colors.white.withOpacity(0.1)
        //             : Colors.black.withOpacity(0.1),
        //       ),
        //     ),
        //     child: Column(
        //       children: [
        //         // Rating Selector
        //         Container(
        //           padding: const EdgeInsets.all(16),
        //           decoration: BoxDecoration(
        //             border: Border(
        //               bottom: BorderSide(
        //                 color: isDark
        //                     ? Colors.white.withOpacity(0.1)
        //                     : Colors.black.withOpacity(0.1),
        //               ),
        //             ),
        //           ),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 'Rate your experience',
        //                 style: theme.textTheme.bodyMedium?.copyWith(
        //                   fontWeight: FontWeight.w500,
        //                 ),
        //               ),
        //               const SizedBox(height: 8),
        //               Row(
        //                 children: List.generate(5, (index) {
        //                   final starValue = index + 1;
        //                   return GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         _rating = starValue;
        //                       });
        //                     },
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(right: 4),
        //                       child: Icon(
        //                         _rating >= starValue
        //                             ? Icons.star_rounded
        //                             : Icons.star_outline_rounded,
        //                         size: 32,
        //                         color: _rating >= starValue
        //                             ? const Color(0xFFFFD700)
        //                             : isDark
        //                                 ? Colors.white.withOpacity(0.3)
        //                                 : Colors.black.withOpacity(0.3),
        //                       ),
        //                     ),
        //                   );
        //                 }),
        //               ),
        //             ],
        //           ),
        //         ),
        //         // Comment TextField
        //         TextField(
        //           controller: _commentController,
        //           style: theme.textTheme.bodyLarge,
        //           maxLines: 3,
        //           decoration: InputDecoration(
        //             hintText: 'Write a comment...',
        //             hintStyle: theme.textTheme.bodyLarge?.copyWith(
        //               color: theme.colorScheme.onSurface.withOpacity(0.5),
        //             ),
        //             border: InputBorder.none,
        //             contentPadding: const EdgeInsets.all(16),
        //           ),
        //         ),
        //         // Anonymous Checkbox
        //         Container(
        //           decoration: BoxDecoration(
        //             border: Border(
        //               top: BorderSide(
        //                 color: isDark
        //                     ? Colors.white.withOpacity(0.1)
        //                     : Colors.black.withOpacity(0.1),
        //               ),
        //             ),
        //           ),
        //           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        //           child: Row(
        //             children: [
        //               InkWell(
        //                 onTap: () {
        //                   setState(() {
        //                     _isAnonymous = !_isAnonymous;
        //                   });
        //                 },
        //                 borderRadius: BorderRadius.circular(4),
        //                 child: Container(
        //                   width: 18,
        //                   height: 18,
        //                   decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(4),
        //                     border: Border.all(
        //                       color: _isAnonymous
        //                           ? (isDark ? Colors.white : Colors.black)
        //                           : (isDark
        //                               ? Colors.white.withOpacity(0.3)
        //                               : Colors.black.withOpacity(0.3)),
        //                       width: 1.5,
        //                     ),
        //                     color: _isAnonymous
        //                         ? (isDark ? Colors.white : Colors.black)
        //                         : Colors.transparent,
        //                   ),
        //                   child: _isAnonymous
        //                       ? Icon(
        //                           Icons.check,
        //                           size: 14,
        //                           color: isDark ? Colors.black : Colors.white,
        //                         )
        //                       : null,
        //                 ),
        //               ),
        //               const SizedBox(width: 8),
        //               Text(
        //                 'Comment anonymously',
        //                 style: theme.textTheme.bodyMedium?.copyWith(
        //                   color: isDark
        //                       ? Colors.white.withOpacity(0.7)
        //                       : Colors.black.withOpacity(0.7),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         // Submit Button Container
        //         Container(
        //           decoration: BoxDecoration(
        //             border: Border(
        //               top: BorderSide(
        //                 color: isDark
        //                     ? Colors.white.withOpacity(0.1)
        //                     : Colors.black.withOpacity(0.1),
        //               ),
        //             ),
        //           ),
        //           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Text(
        //                 'Be respectful in comments',
        //                 style: theme.textTheme.bodySmall?.copyWith(
        //                   color: theme.colorScheme.onSurface.withOpacity(0.5),
        //                 ),
        //               ),
        //               Consumer(
        //                 builder: (context, ref, child) {
        //                   return TextButton(
        //                     onPressed: _isSubmitting
        //                         ? null
        //                         : () => _submitComment(ref),
        //                     style: TextButton.styleFrom(
        //                       backgroundColor: isDark
        //                           ? Colors.white.withOpacity(0.1)
        //                           : Colors.black,
        //                       padding: const EdgeInsets.symmetric(
        //                           horizontal: 16, vertical: 8),
        //                       shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.circular(8),
        //                       ),
        //                     ),
        //                     child: _isSubmitting
        //                         ? SizedBox(
        //                             height: 20,
        //                             width: 20,
        //                             child: CircularProgressIndicator(
        //                               strokeWidth: 2,
        //                               valueColor: AlwaysStoppedAnimation<Color>(
        //                                 isDark ? Colors.white : Colors.white,
        //                               ),
        //                             ),
        //                           )
        //                         : Text(
        //                             'Comment',
        //                             style: theme.textTheme.bodyMedium?.copyWith(
        //                               color:
        //                                   isDark ? Colors.white : Colors.white,
        //                               fontWeight: FontWeight.w500,
        //                             ),
        //                           ),
        //                   );
        //                 },
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 24),

        // Comments List
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          Center(
            child: Text(
              'No comments yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _comments.length; i++) ...[
                  Opacity(
                    opacity: (_comments[i]['opacity'] ?? 1.0) as double,
                    child: _CommentItem(
                      comment: _comments[i],
                      isDark: isDark,
                      teacherId: widget.teacherId,
                      onReplySubmitted: _fetchComments,
                      showReplies: true,
                    ),
                  ),
                  if (i < _comments.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final bool isDark;
  final String teacherId;
  final VoidCallback onReplySubmitted;
  final bool showReplies;

  const _CommentItem({
    required this.comment,
    required this.isDark,
    required this.teacherId,
    required this.onReplySubmitted,
    this.showReplies = true,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  final bool _showReplyBox = false;
  bool _isVoting = false;
  String? _userVote; // 'upVote', 'downVote', or null
  int? _upVotesCount;
  int? _downVotesCount;

  @override
  void initState() {
    super.initState();
    final userId = _currentUserId(context);
    final userVotes = widget.comment['userVotes'];
    // log("message1 user vote $userVotes \n $_userVote and ");

    if (userVotes != null && userId != null && userVotes is Map) {
      _userVote = userVotes[userId] as String?;
      // log("message user vote $userVotes \n $_userVote and ${userVotes[userId]}");
    } else {
      _userVote = null;
    }
    _upVotesCount = widget.comment['upVotesCount'] ?? 0;
    _downVotesCount = widget.comment['downVotesCount'] ?? 0;
  }

  String? _currentUserId(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final user = container.read(authProvider).user;
    return user != null ? user['_id'] as String? : null;
  }

  Future<void> _handleVote(String voteType) async {
    if (_isVoting) return;
    setState(() {
      _isVoting = true;
      // Optimistic update
      String? prevVote = _userVote;
      if (_userVote == voteType) {
        // Undo vote
        if (voteType == 'upVote') _upVotesCount = (_upVotesCount ?? 1) - 1;
        if (voteType == 'downVote') {
          _downVotesCount = (_downVotesCount ?? 1) - 1;
        }
        _userVote = null;
      } else {
        if (voteType == 'upVote') {
          _upVotesCount = (_upVotesCount ?? 0) + 1;
          if (_userVote == 'downVote') {
            _downVotesCount = (_downVotesCount ?? 1) - 1;
          }
        } else if (voteType == 'downVote') {
          _downVotesCount = (_downVotesCount ?? 0) + 1;
          if (_userVote == 'upVote') _upVotesCount = (_upVotesCount ?? 1) - 1;
        }
        _userVote = voteType;
      }
    });
    final userId = _currentUserId(context);
    if (userId == null) {
      setState(() {
        _isVoting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to vote.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final reviewId = widget.comment['_id'];
    final userIdOther = widget.comment['user']?['_id'];
    if (reviewId == null || userIdOther == null) {
      setState(() {
        _isVoting = false;
      });
      return;
    }
    // Save previous state for revert
    String? prevVote = _userVote;
    int prevUp = _upVotesCount ?? 0;
    int prevDown = _downVotesCount ?? 0;
    try {
      final apiClient = ApiClient();
      final response = await apiClient.post(
        '/api/teacher/reviews/feedbacks/vote',
        {
          'reviewId': reviewId,
          'userIdOther': userIdOther,
          'voteType': voteType,
        },
      );
      if (response.isNotEmpty) {
        log("RESPONSE FROM VOTE $response");
        setState(() {
          _upVotesCount = response['upVotesCount'] ?? _upVotesCount;
          _downVotesCount = response['downVotesCount'] ?? _downVotesCount;
          if (response['noneSelected'] == true) {
            _userVote = null;
          } else {
            _userVote = voteType;
          }
        });
      }
    } catch (e) {
      // Revert optimistic update
      setState(() {
        _userVote = prevVote;
        _upVotesCount = prevUp;
        _downVotesCount = prevDown;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to vote. Please try again.'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isVoting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.comment['user'];
    final name = user['name'] ?? 'Anonymous';
    final isDeleted = user['_id'] == null;
    final isAnonymous = widget.comment['isAnonymous'] ?? false;

    log("_________________\n _____________ \n Comment " +
        widget.comment.toString());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                child: Text(
                  name[0].toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAnonymous ? 'Anonymous' : name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDeleted
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.5)
                                    : null,
                              ),
                            ),
                            if (!isDeleted &&
                                !isAnonymous &&
                                user['isVerified'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Colors.blue,
                              ),
                              if (widget.comment['isEdited'] == true)
                                Text('(Edited)'),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (widget.comment['favouritedByTeacher'] == true)
                              const Icon(
                                Icons.favorite,
                                size: 18,
                              ),
                            const SizedBox(
                              width: 10,
                            ),
                            // Rating Stars
                            if (widget.comment['rating'] != null)
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < (widget.comment['rating'] as int)
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 16,
                                    color: index <
                                            (widget.comment['rating'] as int)
                                        ? const Color(0xFFFFD700)
                                        : widget.isDark
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.3),
                                  );
                                }),
                              ),
                          ],
                        )
                      ],
                    ),
                    Text(
                      widget.comment['updatedAt'] != null
                          ? _formatDate(widget.comment['updatedAt'])
                          : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              widget.comment['feedback'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (widget.comment['teacherDirectComment'] != null)
            Container(
              margin: const EdgeInsets.only(left: 44, top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: widget.isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Teacher Response',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.comment['teacherDirectComment']['comment'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(
                        widget.comment['teacherDirectComment']['createdAt']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              children: [
                _VoteButton(
                  icon: Icons.arrow_upward_rounded,
                  count: _upVotesCount ?? 0,
                  isDark: widget.isDark,
                  onPressed: _isVoting ? null : () => _handleVote('upVote'),
                  isSelected: _userVote?.toLowerCase() == 'upvote',
                ),
                const SizedBox(width: 16),
                _VoteButton(
                  icon: Icons.arrow_downward_rounded,
                  count: _downVotesCount ?? 0,
                  isDark: widget.isDark,
                  onPressed: _isVoting ? null : () => _handleVote('downVote'),
                  isSelected: _userVote?.toLowerCase() == 'downvote',
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    // Pass the updated comment map with latest votes and userVotes
                    final updatedComment =
                        Map<String, dynamic>.from(widget.comment)
                          ..['upVotesCount'] = _upVotesCount
                          ..['downVotesCount'] = _downVotesCount
                          ..['userVotes'] = {
                            ...?widget.comment['userVotes'],
                            _currentUserId(context): _userVote
                          };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentDetailsPage(
                          comment: updatedComment,
                          teacherId: widget.teacherId,
                          isDark: widget.isDark,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: widget.isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.comment_outlined,
                    size: 20,
                  ),
                  label: Text(
                    'View Replies',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class _ReplyItem extends StatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDark;
  final String teacherId;

  const _ReplyItem({
    required this.reply,
    required this.isDark,
    required this.teacherId,
  });

  @override
  State<_ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<_ReplyItem> {
  bool _showReplyBox = false;
  bool _showReactionPicker = false;
  Map<String, dynamic>? _selectedReaction;

  final List<Map<String, dynamic>> _reactions = [
    {'emoji': '😄', 'type': 'haha'},
    {'emoji': '😢', 'type': 'sad'},
    {'emoji': '❤️', 'type': 'love'},
    {'emoji': '😠', 'type': 'angry'},
    {'emoji': '💡', 'type': 'insightful'},
  ];

  @override
  void initState() {
    super.initState();
    // Find if user has already reacted
    final reactions = widget.reply['reactions'] as Map<String, dynamic>?;
    if (reactions != null) {
      for (final reaction in _reactions) {
        if (reactions[reaction['type']] != null) {
          _selectedReaction = reaction;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.reply['user'] ?? {};
    final name = user['name'] ?? '[deleted]';
    final isDeleted = user['_id'] == null;
    final isAnonymous = widget.reply['isAnonymous'] ?? false;
    final date = widget.reply['updatedAt'] ?? widget.reply['createdAt'] ?? '';
    final replyText = widget.reply['comment'] ?? widget.reply['text'] ?? '';
    final gifUrl = widget.reply['gifUrl'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: widget.isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  child: Text(
                    (isAnonymous ? 'A' : name[0]).toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        isAnonymous ? 'Anonymous' : name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDeleted
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : null,
                        ),
                      ),
                      if (!isDeleted &&
                          !isAnonymous &&
                          user['isVerified'] == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatDate(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              replyText,
              style: theme.textTheme.bodyMedium,
            ),
            if (gifUrl != null && gifUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gifUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Reaction Buttons
            Row(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    // Show selected reaction if exists
                    if (_selectedReaction != null)
                      _ReactionButton(
                        emoji: _selectedReaction!['emoji'] as String,
                        count: 1,
                        isDark: widget.isDark,
                        isSelected: true,
                        onPressed: () {
                          setState(() {
                            _selectedReaction = null;
                          });
                        },
                      ),
                    // Show existing reactions from others
                    for (final reaction in _reactions)
                      if ((widget.reply['reactions']?[reaction['type']] ?? 0) >
                              0 &&
                          _selectedReaction?['type'] != reaction['type'])
                        _ReactionButton(
                          emoji: reaction['emoji'] as String,
                          count:
                              widget.reply['reactions']?[reaction['type']] ?? 0,
                          isDark: widget.isDark,
                          isSelected: false,
                          onPressed: () {
                            setState(() {
                              _selectedReaction = reaction;
                            });
                          },
                        ),
                    // Show add reaction button if no reaction selected
                    if (_selectedReaction == null)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showReactionPicker = !_showReactionPicker;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_reaction_outlined,
                            size: 20,
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.7)
                                : Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showReplyBox = !_showReplyBox;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: widget.isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.reply_rounded,
                    size: 20,
                  ),
                  label: Text(
                    'Reply',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (_showReactionPicker) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final reaction in _reactions) ...[
                      if (reaction != _reactions.first)
                        const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedReaction = reaction;
                            _showReactionPicker = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reaction['emoji'] as String,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_showReplyBox) ...[
              const SizedBox(height: 12),
              _ReplyBox(
                isDark: widget.isDark,
                onSubmit: () {
                  setState(() {
                    _showReplyBox = false;
                  });
                },
                teacherId: widget.teacherId,
                parentId: widget.reply['_id'],
                isReplyToReply: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';

    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class _ReplyBox extends StatefulWidget {
  final bool isDark;
  final VoidCallback onSubmit;
  final String teacherId;
  final String? parentId;
  final bool isReplyToReply;

  const _ReplyBox({
    required this.isDark,
    required this.onSubmit,
    required this.teacherId,
    required this.parentId,
    this.isReplyToReply = false,
  });

  @override
  State<_ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<_ReplyBox> {
  final TextEditingController replyController = TextEditingController();
  String? selectedGifUrl;
  bool showGifPicker = false;
  bool showMentionsList = false;
  List<String> mentions = [];
  List<Map<String, dynamic>> mentionSuggestions = [];
  bool isSubmitting = false;

  Future<void> submitReply(WidgetRef ref) async {
    if (replyController.text.trim().isEmpty) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ApiClient apiClient = ApiClient();
      final endpoint = widget.isReplyToReply
          ? '/api/teacher/reply/reply/feedback'
          : '/api/teacher/reply/feedback';

      final response = await apiClient.post(
        endpoint,
        {
          'teacherId': widget.teacherId,
          widget.isReplyToReply ? 'feedbackCommentId' : 'feedbackReviewId':
              widget.parentId,
          'feedbackComment': replyController.text.trim(),
          'gifUrl': selectedGifUrl ?? '',
          'mentions': mentions,
        },
      );

      replyController.clear();
      setState(() {
        selectedGifUrl = null;
        mentions = [];
        isSubmitting = false;
      });
      widget.onSubmit();

      // After submitting, fetch updated replies
      if (widget.isReplyToReply) {
        // Fetch replies to replies
        final repliesResponse = await apiClient.get(
          '/api/teacher/reply/reply/feedback',
          queryParameters: {'feedbackCommentId': widget.parentId},
        );
        // Handle the updated replies
        if (mounted && repliesResponse['replies'] != null) {
          // Update the UI with new replies
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reply posted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Fetch root level replies
        final repliesResponse = await apiClient.get(
          '/api/teacher/reviews/feedbacks',
          queryParameters: {'id': widget.teacherId},
        );
        // Handle the updated replies
        if (mounted && repliesResponse != null) {
          // Update the UI with new replies
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reply posted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post reply: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void handleTextChange(String value) async {
    final lastWord = value.split(' ').last;
    if (lastWord.startsWith('@') && lastWord.length > 1) {
      final searchQuery = lastWord.substring(1);
      try {
        final ApiClient apiClient = ApiClient();
        final response = await apiClient.get(
          ApiConstants.searchUsers,
          queryParameters: {'q': searchQuery},
        );

        setState(() {
          mentionSuggestions =
              List<Map<String, dynamic>>.from(response['users']);
          showMentionsList = true;
        });
      } catch (e) {
        print('Error searching users: $e');
      }
    } else {
      setState(() {
        showMentionsList = false;
      });
    }
  }

  void handleMentionSelected(Map<String, dynamic> user) {
    final text = replyController.text;
    final lastAtIndex = text.lastIndexOf('@');
    if (lastAtIndex != -1) {
      final newText = '${text.substring(0, lastAtIndex)}@${user['username']} ';
      replyController.text = newText;
      replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }
    setState(() {
      mentions.add(user['_id']);
      showMentionsList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          if (selectedGifUrl != null) ...[
            Stack(
              children: [
                Image.network(
                  selectedGifUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        selectedGifUrl = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showGifPicker = !showGifPicker;
                  });
                },
                icon: const Icon(Icons.gif_box_outlined),
                color: widget.isDark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
              ),
              Expanded(
                child: TextField(
                  controller: replyController,
                  onChanged: handleTextChange,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Write a reply... Use @ to mention',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return TextButton(
                    onPressed: isSubmitting ? null : () => submitReply(ref),
                    style: TextButton.styleFrom(
                      backgroundColor: widget.isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isDark ? Colors.white : Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Reply',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  widget.isDark ? Colors.white : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
          if (showGifPicker)
            Container(
              height: 300,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: GifPicker(
                isDark: widget.isDark,
                onGifSelected: (gifUrl) {
                  setState(() {
                    selectedGifUrl = gifUrl;
                    showGifPicker = false;
                  });
                },
              ),
            ),
          if (showMentionsList)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mentionSuggestions.length,
                itemBuilder: (context, index) {
                  final user = mentionSuggestions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: widget.isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      child: Text(
                        user['name'][0].toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '@${user['username']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    onTap: () => handleMentionSelected(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isDark;
  final VoidCallback? onPressed;
  final bool isSelected;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isDark,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.12))
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7)),
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final int count;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ReactionButton({
    required this.emoji,
    required this.count,
    required this.isDark,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1))
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
