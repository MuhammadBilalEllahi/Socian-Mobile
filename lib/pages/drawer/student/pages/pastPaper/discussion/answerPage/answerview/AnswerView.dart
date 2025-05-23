import 'package:socian/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widgets/EditAnswer.dart';

class AnswerView extends StatefulWidget {
  final String content;
  final String answerId;
  final String questionId;
  const AnswerView({
    super.key,
    required this.answerId,
    required this.content,
    required this.questionId,
  });

  @override
  State<AnswerView> createState() => _AnswerViewState();
}

class _AnswerViewState extends State<AnswerView> {
  final _commentTextController = TextEditingController();
  final _replyTextController = TextEditingController();
  final _editAnswerController = TextEditingController();
  final _apiClient = ApiClient();
  List<dynamic> comments = [];
  bool isLoading = false;
  Map<String, dynamic>? answerData;
  bool isVoting = false;
  String? userAnswerVoteType; // 'upvote', 'downvote', or null
  int answerUpVotes = 0;
  int answerDownVotes = 0;
  Map<String, bool> commentVoting = {}; // commentId -> isVoting
  Map<String, String?> commentUserVoteType =
      {}; // commentId -> 'upvote'/'downvote'/null
  String? replyingToCommentId; // The commentId being replied to
  String? replyingToUserName; // The user name being replied to

  // For storing replies per commentId
  Map<String, List<dynamic>> commentReplies = {};
  Map<String, bool> commentRepliesLoading = {};

  // For edit/delete
  bool isEditingAnswer = false;
  bool isDeletingAnswer = false;
  bool showEditDialog = false;
  bool showDeleteDialog = false;
  String? currentUserId; // Set after fetching answerData

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchAnswerData();
  }

  Future<void> _fetchComments() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await _apiClient
          .get('/api/discussion/answer/comments?answerId=${widget.answerId}');
      // debugPrint("COMMENTS $response");
      final commentList = (response is Map && response['comment'] is List)
          ? response['comment'] as List<dynamic>
          : <dynamic>[];
      final Map<String, String?> userVoteTypeMap = {};
      for (final comment in commentList) {
        if (comment is Map && comment['voteId'] is Map) {
          final voteId = comment['voteId'] as Map;
          userVoteTypeMap[comment['_id'] ?? ''] =
              voteId['userVoteType'] as String?;
        } else {
          userVoteTypeMap[comment['_id'] ?? ''] = null;
        }
      }
      setState(() {
        comments = commentList;
        isLoading = false;
        commentUserVoteType = userVoteTypeMap;
        commentReplies.clear();
        commentRepliesLoading.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCommentReplies(String commentId) async {
    setState(() {
      commentRepliesLoading[commentId] = true;
    });
    try {
      final response = await _apiClient
          .get('/api/discussion/answer/comment/replies?commentId=$commentId');
      final List<dynamic> replies =
          (response is Map && response['comment'] is List)
              ? response['comment'] as List<dynamic>
              : <dynamic>[];
      setState(() {
        commentReplies[commentId] = replies;
        commentRepliesLoading[commentId] = false;
      });
    } catch (e) {
      setState(() {
        commentRepliesLoading[commentId] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load replies: $e')),
        );
      }
    }
  }

  Future<void> _fetchAnswerData() async {
    try {
      final response2 = await _apiClient
          .get('/api/discussion/answer?answerId=${widget.answerId}');
      final response = (response2 is Map && response2['data'] is Map)
          ? response2['data'] as Map<String, dynamic>
          : null;
      if (response != null && response['content'] != null) {
        // Try to get vote info if present
        int upVotes = 0;
        int downVotes = 0;
        String? userVoteType;
        if (response['voteId'] is Map) {
          final voteId = response['voteId'] as Map;
          upVotes = voteId['upVotesCount'] is int ? voteId['upVotesCount'] : 0;
          downVotes =
              voteId['downVotesCount'] is int ? voteId['downVotesCount'] : 0;
          userVoteType = voteId['userVoteType'] as String?;
        } else {
          upVotes = response['upvotes'] ?? 0;
          downVotes = response['downvotes'] ?? 0;
          userVoteType = null;
        }
        // Set currentUserId for edit/delete check
        String? userId;
        if (response['answeredByUser'] is Map &&
            response['answeredByUser']['_id'] != null) {
          userId = response['answeredByUser']['_id'];
        }
        setState(() {
          answerData = response;
          answerUpVotes = upVotes;
          answerDownVotes = downVotes;
          userAnswerVoteType = userVoteType;
          currentUserId = userId;
        });
      }
    } catch (e) {}
  }

  Future<void> _vote(String type) async {
    if (isVoting) return;
    setState(() {
      isVoting = true;
    });
    try {
      final response = await _apiClient.post('/api/discussion/answer/vote', {
        'answerId': widget.answerId,
        'voteType': type,
      });

      // The backend returns upVotesCount, downVotesCount, and possibly noneSelected
      if (response is Map) {
        int upVotes = response['upVotesCount'] is int
            ? response['upVotesCount']
            : answerUpVotes;
        int downVotes = response['downVotesCount'] is int
            ? response['downVotesCount']
            : answerDownVotes;
        bool noneSelected = response['noneSelected'] == true;
        setState(() {
          answerUpVotes = upVotes;
          answerDownVotes = downVotes;
          userAnswerVoteType = noneSelected ? null : type;
        });
      }
      // Optionally, update answerData as well
      if (answerData != null) {
        setState(() {
          if (answerData!['voteId'] is Map) {
            answerData!['voteId']['upVotesCount'] = answerUpVotes;
            answerData!['voteId']['downVotesCount'] = answerDownVotes;
            answerData!['voteId']['userVoteType'] = userAnswerVoteType;
          } else {
            answerData!['upvotes'] = answerUpVotes;
            answerData!['downvotes'] = answerDownVotes;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote: $e')),
        );
      }
    }
    setState(() {
      isVoting = false;
    });
  }

  Future<void> _voteComment(String commentId, String voteType) async {
    if (commentVoting[commentId] == true) return;
    setState(() {
      commentVoting[commentId] = true;
    });
    try {
      final response =
          await _apiClient.post('/api/discussion/answer/comment/vote', {
        'commentId': commentId,
        'voteType': voteType,
      });
      final int index = comments.indexWhere((c) => c['_id'] == commentId);
      if (index != -1) {
        final comment = Map<String, dynamic>.from(comments[index]);
        if (comment['voteId'] is Map) {
          final voteId = Map<String, dynamic>.from(comment['voteId']);
          voteId['upVotesCount'] =
              response['upVotesCount'] ?? voteId['upVotesCount'];
          voteId['downVotesCount'] =
              response['downVotesCount'] ?? voteId['downVotesCount'];
          if (response['noneSelected'] == true) {
            voteId['userVoteType'] = null;
            commentUserVoteType[commentId] = null;
          } else {
            voteId['userVoteType'] = voteType;
            commentUserVoteType[commentId] = voteType;
          }
          comment['voteId'] = voteId;
        } else {
          comment['voteId'] = {
            'upVotesCount': response['upVotesCount'] ?? 0,
            'downVotesCount': response['downVotesCount'] ?? 0,
            'userVoteType': response['noneSelected'] == true ? null : voteType,
          };
          commentUserVoteType[commentId] =
              response['noneSelected'] == true ? null : voteType;
        }
        setState(() {
          comments[index] = comment;
        });
      }
      // Also update the reply in commentReplies if present
      for (final entry in commentReplies.entries) {
        final replies = entry.value;
        final replyIndex = replies.indexWhere((r) => r['_id'] == commentId);
        if (replyIndex != -1) {
          final reply = Map<String, dynamic>.from(replies[replyIndex]);
          if (reply['voteId'] is Map) {
            final voteId = Map<String, dynamic>.from(reply['voteId']);
            voteId['upVotesCount'] =
                response['upVotesCount'] ?? voteId['upVotesCount'];
            voteId['downVotesCount'] =
                response['downVotesCount'] ?? voteId['downVotesCount'];
            if (response['noneSelected'] == true) {
              voteId['userVoteType'] = null;
              commentUserVoteType[commentId] = null;
            } else {
              voteId['userVoteType'] = voteType;
              commentUserVoteType[commentId] = voteType;
            }
            reply['voteId'] = voteId;
          } else {
            reply['voteId'] = {
              'upVotesCount': response['upVotesCount'] ?? 0,
              'downVotesCount': response['downVotesCount'] ?? 0,
              'userVoteType':
                  response['noneSelected'] == true ? null : voteType,
            };
            commentUserVoteType[commentId] =
                response['noneSelected'] == true ? null : voteType;
          }
          setState(() {
            commentReplies[entry.key]![replyIndex] = reply;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote on comment: $e')),
        );
      }
    }
    setState(() {
      commentVoting[commentId] = false;
    });
  }

  // Use the same vote route for replies as for comments
  Future<void> _voteReply(String replyId, String voteType) async {
    if (commentVoting[replyId] == true) return;
    setState(() {
      commentVoting[replyId] = true;
    });
    try {
      final response =
          await _apiClient.post('/api/discussion/answer/comment/vote', {
        'commentId': replyId,
        'voteType': voteType,
      });
      // Update the reply in commentReplies
      for (final entry in commentReplies.entries) {
        final replies = entry.value;
        final replyIndex = replies.indexWhere((r) => r['_id'] == replyId);
        if (replyIndex != -1) {
          final reply = Map<String, dynamic>.from(replies[replyIndex]);
          if (reply['voteId'] is Map) {
            final voteId = Map<String, dynamic>.from(reply['voteId']);
            voteId['upVotesCount'] =
                response['upVotesCount'] ?? voteId['upVotesCount'];
            voteId['downVotesCount'] =
                response['downVotesCount'] ?? voteId['downVotesCount'];
            if (response['noneSelected'] == true) {
              voteId['userVoteType'] = null;
              commentUserVoteType[replyId] = null;
            } else {
              voteId['userVoteType'] = voteType;
              commentUserVoteType[replyId] = voteType;
            }
            reply['voteId'] = voteId;
          } else {
            reply['voteId'] = {
              'upVotesCount': response['upVotesCount'] ?? 0,
              'downVotesCount': response['downVotesCount'] ?? 0,
              'userVoteType':
                  response['noneSelected'] == true ? null : voteType,
            };
            commentUserVoteType[replyId] =
                response['noneSelected'] == true ? null : voteType;
          }
          setState(() {
            commentReplies[entry.key]![replyIndex] = reply;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote on reply: $e')),
        );
      }
    }
    setState(() {
      commentVoting[replyId] = false;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentTextController.text.trim();
    if (text.isEmpty) return;
    try {
      await _apiClient.post('/api/discussion/answer/comment/add-comment', {
        'answerId': widget.answerId,
        'commentContent': text,
        'questionId': widget.questionId
      });
      _commentTextController.clear();
      await _fetchComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  Future<void> _submitReply(String commentId) async {
    final text = _replyTextController.text.trim();
    if (text.isEmpty) return;
    try {
      await _apiClient.post('/api/discussion/answer/comment/add-reply', {
        'commentId': commentId,
        'commentContent': text,
        'mentions': [],
      });
      _replyTextController.clear();
      setState(() {
        replyingToCommentId = null;
        replyingToUserName = null;
      });
      await _fetchComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add reply: $e')),
        );
      }
    }
  }

  Future<void> _editAnswer(String editedContent, String userIdRef) async {
    if (isEditingAnswer) return;
    setState(() {
      isEditingAnswer = true;
    });
    try {
      final userIdRef = currentUserId;
      final response = await _apiClient.post('/api/discussion/answer/edit', {
        'answerId': widget.answerId,
        'editedContent': editedContent,
        'userIdRef': userIdRef,
      });
      if (response is Map && response['data'] != null) {
        setState(() {
          answerData = response['data'];
          showEditDialog = false;
        });
        await _fetchAnswerData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Answer edited successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Failed to edit answer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit answer: $e')),
        );
      }
    }
    setState(() {
      isEditingAnswer = false;
    });
  }

  Future<void> _deleteAnswer() async {
    if (isDeletingAnswer) return;
    setState(() {
      isDeletingAnswer = true;
    });
    try {
      final userIdRef = currentUserId;
      final response = await _apiClient.post('/api/discussion/answer/delete', {
        'answerId': widget.answerId,
        'userIdRef': userIdRef,
      });
      if (response is Map &&
          response['message'] == 'Answer deleted successfully') {
        setState(() {
          showDeleteDialog = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Answer deleted successfully')),
          );
          Navigator.of(context).pop(); // Go back after deletion
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(response['message'] ?? 'Failed to delete answer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete answer: $e')),
        );
      }
    }
    setState(() {
      isDeletingAnswer = false;
    });
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _replyTextController.dispose();
    _editAnswerController.dispose();
    super.dispose();
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('yMMMd').add_jm().format(date);
    } catch (_) {
      return '';
    }
  }

  Widget _buildReplyWidget(
      Map<String, dynamic> reply, Color foreground, Color mutedForeground) {
    final user = reply['user'] ?? {};
    final profile = user['profile'] ?? {};
    final avatarUrl = profile['picture'] ??
        'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg';
    final name = user['name'] ?? 'Unknown';
    final username = user['username'] ?? '';
    final content = reply['content'] ?? '';
    final createdAt = reply['createdAt']?.toString();
    final replyId = reply['_id'] ?? '';

    int upvotes = 0;
    int downvotes = 0;
    String? userVoteType;
    if (reply['voteId'] is Map) {
      final voteId = reply['voteId'] as Map;
      upvotes = voteId['upVotesCount'] is int ? voteId['upVotesCount'] : 0;
      downvotes =
          voteId['downVotesCount'] is int ? voteId['downVotesCount'] : 0;
      userVoteType = voteId['userVoteType'] as String?;
    } else {
      upvotes = reply['upvotes'] ?? 0;
      downvotes = reply['downvotes'] ?? 0;
      userVoteType = null;
    }

    final isReplyVoting = commentVoting[replyId] == true;

    return Container(
      margin: const EdgeInsets.only(left: 40, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 14,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: const TextStyle(
                      color: Color(0xFF09090B),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            color: Color(0xFF71717A),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2),
                      ),
                      if (username.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '@$username',
                          style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.2),
                        ),
                      ],
                      if (createdAt != null && createdAt.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 10,
                              letterSpacing: -0.2),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: isReplyVoting
                            ? null
                            : () => _voteReply(replyId, 'upvote'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                size: 13,
                                color: isReplyVoting
                                    ? Colors.grey[400]
                                    : (userVoteType == 'upvote'
                                        ? Colors.blue
                                        : mutedForeground),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                upvotes.toString(),
                                style: TextStyle(
                                  color: isReplyVoting
                                      ? Colors.grey[400]
                                      : (userVoteType == 'upvote'
                                          ? Colors.blue
                                          : mutedForeground),
                                  fontSize: 11,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: isReplyVoting
                            ? null
                            : () => _voteReply(replyId, 'downvote'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_down,
                                size: 13,
                                color: isReplyVoting
                                    ? Colors.grey[400]
                                    : (userVoteType == 'downvote'
                                        ? Colors.red
                                        : mutedForeground),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                downvotes.toString(),
                                style: TextStyle(
                                  color: isReplyVoting
                                      ? Colors.grey[400]
                                      : (userVoteType == 'downvote'
                                          ? Colors.red
                                          : mutedForeground),
                                  fontSize: 11,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          setState(() {
                            replyingToCommentId = replyId;
                            replyingToUserName = name;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.reply, size: 13, color: mutedForeground),
                            const SizedBox(width: 2),
                            Text(
                              'Reply',
                              style: TextStyle(
                                color: mutedForeground,
                                fontSize: 11,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (replyingToCommentId == replyId)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyTextController,
                              style: const TextStyle(
                                  color: Color(0xFF09090B), fontSize: 13),
                              decoration: InputDecoration(
                                hintText: replyingToUserName != null
                                    ? 'Reply to $replyingToUserName...'
                                    : 'Reply...',
                                hintStyle: const TextStyle(
                                    color: Color(0xFF71717A), fontSize: 13),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE4E4E7)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE4E4E7)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF09090B)),
                                ),
                              ),
                              onSubmitted: (_) => _submitReply(replyId),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => _submitReply(replyId),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFE4E4E7)),
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.send,
                                    color: Color(0xFF09090B), size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerCard(
    BuildContext context,
    Map<String, dynamic> answer,
    Color foreground,
    Color mutedForeground,
    Color accent,
  ) {
    final user = answer['answeredByUser'] ?? {};
    final profile = user['profile'] ?? {};
    final avatarUrl = profile['picture'] ??
        'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg';
    final name = user['name'] ?? 'Unknown';
    final username = user['username'] ?? '';
    final content = answer['content'] ?? '';
    final userId = user['_id'] ?? '';
    // Use local state for upvotes/downvotes/userVoteType
    final upvotes = answerUpVotes;
    final downvotes = answerDownVotes;
    final isApproved = answer['isApproved'] == true;
    final isCorrect = answer['isCorrect'] == true;
    final answeredAt = answer['answeredAt']?.toString();
    final isDeleted = answer['isDeleted'] == true;
    final isEdited = answer['isEdited'] == true;

    // Check if current user is the answer owner
    final bool canEditOrDelete =
        currentUserId != null && userId == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 20,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF09090B),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (username.isNotEmpty)
                    Text(
                      '@$username',
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.2,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (isApproved)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.green, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Approved',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              if (isCorrect)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.blue, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Correct',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              if (canEditOrDelete && !isDeleted)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF71717A)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editAnswerController.text = content;
                      setState(() {
                        showEditDialog = true;
                      });
                    } else if (value == 'delete') {
                      setState(() {
                        showDeleteDialog = true;
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Color(0xFF71717A)),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (isDeleted)
            const Text(
              'This answer has been deleted.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                height: 1.5,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF09090B),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                    height: 1.5,
                  ),
                ),
                if (isEdited)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '(edited)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF71717A),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Upvote button
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: isVoting || isDeleted
                    ? null
                    : () => _vote(
                        userAnswerVoteType == 'upvote' ? 'upvote' : 'upvote'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: isVoting
                            ? Colors.grey[400]
                            : (userAnswerVoteType == 'upvote'
                                ? Colors.blue
                                : Colors.black),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        upvotes.toString(),
                        style: TextStyle(
                          color: isVoting
                              ? Colors.grey[400]
                              : (userAnswerVoteType == 'upvote'
                                  ? Colors.blue
                                  : const Color(0xFF09090B)),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: isVoting || isDeleted
                    ? null
                    : () => _vote(userAnswerVoteType == 'downvote'
                        ? 'downvote'
                        : 'downvote'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_down,
                        color: isVoting
                            ? Colors.grey[400]
                            : (userAnswerVoteType == 'downvote'
                                ? Colors.red
                                : Colors.black),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        downvotes.toString(),
                        style: TextStyle(
                          color: isVoting
                              ? Colors.grey[400]
                              : (userAnswerVoteType == 'downvote'
                                  ? Colors.red
                                  : const Color(0xFF09090B)),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (answeredAt != null && answeredAt.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 15, color: const Color(0xFF71717A)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(answeredAt),
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Edit dialog
          if (showEditDialog)
            EditAnswer(
              initialContent: content,
              isLoading: isEditingAnswer,
              onSave: (edited, userIdRef) => _editAnswer(edited, userIdRef),
              onCancel: () => setState(() => showEditDialog = false),
            ),
          // Delete dialog
          if (showDeleteDialog) _buildDeleteDialog(context),
        ],
      ),
    );
  }

  Widget _buildDeleteDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Answer'),
      content: const Text(
          'Are you sure you want to delete this answer? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: isDeletingAnswer
              ? null
              : () {
                  setState(() {
                    showDeleteDialog = false;
                  });
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: isDeletingAnswer ? null : _deleteAnswer,
          child: isDeletingAnswer
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Widget _buildRepliesSection(
      String commentId, Color foreground, Color mutedForeground) {
    final isLoadingReplies = commentRepliesLoading[commentId] == true;
    final replies = commentReplies[commentId] ?? [];

    if (isLoadingReplies) {
      return const Padding(
        padding: EdgeInsets.only(left: 40, top: 8, bottom: 8),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Color(0xFF71717A),
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: replies
          .map<Widget>(
              (reply) => _buildReplyWidget(reply, foreground, mutedForeground))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always black/white, shadcn style
    const background = Colors.white;
    const foreground = Color(0xFF09090B);
    const mutedForeground = Color(0xFF71717A);
    const accent = Colors.white;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: foreground),
        title: const Text(
          'Answer',
          style: TextStyle(
            color: foreground,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Show widget.content until answerData is fetched, then show full answer card
          answerData == null
              ? Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  decoration: BoxDecoration(
                    color: accent,
                    border:
                        Border.all(color: const Color(0xFFE4E4E7), width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: foreground,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.1,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: foreground,
                          strokeWidth: 2.2,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildAnswerCard(
                  context, answerData!, foreground, mutedForeground, accent),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentTextController,
                    style: const TextStyle(color: foreground, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle:
                          const TextStyle(color: mutedForeground, fontSize: 15),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: foreground),
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: _submitComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      child:
                          const Icon(Icons.send, color: foreground, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (replyingToCommentId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyTextController,
                      style: const TextStyle(color: foreground, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: replyingToUserName != null
                            ? 'Reply to $replyingToUserName...'
                            : 'Reply...',
                        hintStyle: const TextStyle(
                            color: mutedForeground, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: foreground),
                        ),
                      ),
                      onSubmitted: (_) => _submitReply(replyingToCommentId!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _submitReply(replyingToCommentId!),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE4E4E7)),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child:
                            const Icon(Icons.send, color: foreground, size: 18),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: mutedForeground),
                    onPressed: () {
                      setState(() {
                        replyingToCommentId = null;
                        replyingToUserName = null;
                        _replyTextController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 2),
          Expanded(
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: foreground,
                        strokeWidth: 2.2,
                      ),
                    ),
                  )
                : comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.1,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final user = comment['user'] ?? {};
                          final profile = user['profile'] ?? {};
                          final avatarUrl = profile['picture'] ??
                              'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg';
                          final name = user['name'] ?? 'Unknown';
                          final username = user['username'] ?? '';
                          final content = comment['content'] ?? '';
                          final createdAt = comment['createdAt']?.toString();
                          final commentId = comment['_id'] ?? '';

                          int upvotes = 0;
                          int downvotes = 0;
                          String? userVoteType;
                          if (comment['voteId'] is Map) {
                            final voteId = comment['voteId'] as Map;
                            upvotes = voteId['upVotesCount'] is int
                                ? voteId['upVotesCount']
                                : 0;
                            downvotes = voteId['downVotesCount'] is int
                                ? voteId['downVotesCount']
                                : 0;
                            userVoteType = voteId['userVoteType'] as String?;
                            if (userVoteType == null &&
                                commentUserVoteType.containsKey(commentId)) {
                              userVoteType = commentUserVoteType[commentId];
                            }
                          } else {
                            upvotes = comment['upvotes'] ?? 0;
                            downvotes = comment['downvotes'] ?? 0;
                            userVoteType = commentUserVoteType[commentId];
                          }

                          final isCommentVoting =
                              commentVoting[commentId] == true;

                          // Replies are now loaded on demand
                          final List<dynamic> replies =
                              commentReplies[commentId] ?? [];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: const Color(0xFFE4E4E7), width: 1.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(avatarUrl),
                                        radius: 16,
                                        backgroundColor: Colors.grey[200],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              content,
                                              style: const TextStyle(
                                                color: foreground,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: -0.1,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                      color: mutedForeground,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: -0.2),
                                                ),
                                                if (username.isNotEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '@$username',
                                                    style: const TextStyle(
                                                        color: mutedForeground,
                                                        fontSize: 11,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        letterSpacing: -0.2),
                                                  ),
                                                ],
                                                if (createdAt != null &&
                                                    createdAt.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _formatDate(createdAt),
                                                    style: const TextStyle(
                                                        color: mutedForeground,
                                                        fontSize: 11,
                                                        letterSpacing: -0.2),
                                                  ),
                                                ]
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  onTap: isCommentVoting
                                                      ? null
                                                      : () => _voteComment(
                                                          commentId, 'upvote'),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.thumb_up,
                                                          size: 15,
                                                          color: isCommentVoting
                                                              ? Colors.grey[400]
                                                              : (userVoteType ==
                                                                      'upvote'
                                                                  ? Colors.blue
                                                                  : mutedForeground),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          upvotes.toString(),
                                                          style: TextStyle(
                                                            color: isCommentVoting
                                                                ? Colors
                                                                    .grey[400]
                                                                : (userVoteType ==
                                                                        'upvote'
                                                                    ? Colors
                                                                        .blue
                                                                    : mutedForeground),
                                                            fontSize: 12,
                                                            letterSpacing: -0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  onTap: isCommentVoting
                                                      ? null
                                                      : () => _voteComment(
                                                          commentId,
                                                          'downvote'),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 4,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.thumb_down,
                                                          size: 15,
                                                          color: isCommentVoting
                                                              ? Colors.grey[400]
                                                              : (userVoteType ==
                                                                      'downvote'
                                                                  ? Colors.red
                                                                  : mutedForeground),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          downvotes.toString(),
                                                          style: TextStyle(
                                                            color: isCommentVoting
                                                                ? Colors
                                                                    .grey[400]
                                                                : (userVoteType ==
                                                                        'downvote'
                                                                    ? Colors.red
                                                                    : mutedForeground),
                                                            fontSize: 12,
                                                            letterSpacing: -0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  onTap: () async {
                                                    setState(() {
                                                      replyingToCommentId =
                                                          commentId;
                                                      replyingToUserName = name;
                                                    });
                                                    // Load replies if not loaded
                                                    if (!commentReplies
                                                        .containsKey(
                                                            commentId)) {
                                                      await _fetchCommentReplies(
                                                          commentId);
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.reply,
                                                          size: 15,
                                                          color:
                                                              mutedForeground),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        'Reply',
                                                        style: TextStyle(
                                                          color:
                                                              mutedForeground,
                                                          fontSize: 12,
                                                          letterSpacing: -0.2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                // Show "Show replies" button if not loaded
                                                if (!(commentReplies
                                                        .containsKey(
                                                            commentId) &&
                                                    (commentReplies[commentId]
                                                            ?.isNotEmpty ??
                                                        false)))
                                                  InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    onTap: () async {
                                                      await _fetchCommentReplies(
                                                          commentId);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .expand_more_outlined,
                                                          size: 16,
                                                          color:
                                                              mutedForeground,
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          'Show replies',
                                                          style: TextStyle(
                                                            color:
                                                                mutedForeground,
                                                            fontSize: 12,
                                                            letterSpacing: -0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (replyingToCommentId ==
                                                commentId)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _replyTextController,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF09090B),
                                                            fontSize: 13),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              replyingToUserName !=
                                                                      null
                                                                  ? 'Reply to $replyingToUserName...'
                                                                  : 'Reply...',
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: Color(
                                                                      0xFF71717A),
                                                                  fontSize: 13),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Color(
                                                                        0xFFE4E4E7)),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Color(
                                                                        0xFFE4E4E7)),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Color(
                                                                        0xFF09090B)),
                                                          ),
                                                        ),
                                                        onSubmitted: (_) =>
                                                            _submitReply(
                                                                commentId),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        onTap: () =>
                                                            _submitReply(
                                                                commentId),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: const Color(
                                                                    0xFFE4E4E7)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            color: Colors.white,
                                                          ),
                                                          child: const Icon(
                                                              Icons.send,
                                                              color: Color(
                                                                  0xFF09090B),
                                                              size: 16),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Replies section (loaded on demand)
                                  _buildRepliesSection(
                                      commentId, foreground, mutedForeground),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
