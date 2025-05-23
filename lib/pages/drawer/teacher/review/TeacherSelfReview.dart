// features
// 1. show feedbacks from student
// 2. show teacher self info
// 3. comment to a feedback
// 4. teacher message to all students
// content upload by teacher like pdf, links, books url or pdf for students
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:socian/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TeacherSelfReview extends ConsumerStatefulWidget {
  const TeacherSelfReview({super.key});

  @override
  ConsumerState<TeacherSelfReview> createState() => _TeacherSelfReviewState();
}

class _TeacherSelfReviewState extends ConsumerState<TeacherSelfReview> {
  bool _isLoading = true;
  Map<String, dynamic>? _teacherData;
  List<Map<String, dynamic>> _feedbacks = [];
  String? _error;
  String? _message;
  List<Map<String, dynamic>> _teachersInList = [];
  final TextEditingController _replyController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();

    _fetchTeacherData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeacherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final apiClient = ApiClient();
      if (user['teacherConnectivities']['teacherModal'] != null) {
        final response = await apiClient.get(
          '/api/teacher/account/feedbacks',
          queryParameters: {
            'teacherId': user['teacherConnectivities']['teacherModal'],
          },
        );

        setState(() {
          _teacherData = response['teacher'];
          _feedbacks =
              List<Map<String, dynamic>>.from(response['feedbacks'] ?? []);
          _isLoading = false;
        });
      } else {
        final response = await apiClient.get('/api/user/teacher/attachUser');
        setState(() {
          _message = response['message'];
          _teachersInList =
              List<Map<String, dynamic>>.from(response['teachers'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleTeacherSelect(String teacherId) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiClient.get(
        '/api/user/teacher/joinModel',
        queryParameters: {'teacherId': teacherId},
      );

      setState(() {
        _message = response['message'];
        _teacherData = response['teacher'];
        _isLoading = false;
      });

      // After successful attachment, fetch the teacher data
      await _fetchTeacherData();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCreateTeacherProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiClient.post(
        '/api/teacher/by/teacher/create',
        {},
      );

      setState(() {
        _message = 'Teacher profile created successfully';
        _teacherData = response['teacher'];
        _isLoading = false;
      });

      final userData = response['teacherConnectivities'];
      final token = await SecureStorageService.instance.getToken();

      if (token != null) {
        final dataJSON = JwtDecoder.decode(token);
        // Update the specific field
        dataJSON['teacherConnectivities'] = userData;

        final jwt = JWT(dataJSON);

        final convertedToJWT = jwt.sign(SecretKey(dotenv.get('JTM')));

        // Save the entire updated token
        await SecureStorageService.instance.saveToken(convertedToJWT);

        // Update Riverpod state using updateAuthState
        await ref
            .read(authProvider.notifier)
            .updateAuthState(dataJSON, convertedToJWT);

        log("serviceAuthToken $dataJSON");
      }

      // After successful creation, fetch the teacher data
      await _fetchTeacherData();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> toggleFavorite(String ratingId) async {
    try {
      // Find the feedback item in the list
      final feedbackIndex = _feedbacks.indexWhere((f) => f['_id'] == ratingId);
      if (feedbackIndex == -1) return false;

      // Optimistically update the UI
      setState(() {
        _feedbacks[feedbackIndex]['favouritedByTeacher'] =
            !_feedbacks[feedbackIndex]['favouritedByTeacher'];
      });

      final response = await _apiClient.post(
          '/api/teacher/feedback/comment/favorite', {'ratingId': ratingId});

      // Update with actual server response
      setState(() {
        _feedbacks[feedbackIndex]['favouritedByTeacher'] =
            response['rating']['favouritedByTeacher'] ?? false;
      });

      return response['rating']['favouritedByTeacher'] ?? false;
    } catch (e) {
      // Revert optimistic update on error
      final feedbackIndex = _feedbacks.indexWhere((f) => f['_id'] == ratingId);
      if (feedbackIndex != -1) {
        setState(() {
          _feedbacks[feedbackIndex]['favouritedByTeacher'] =
              !_feedbacks[feedbackIndex]['favouritedByTeacher'];
        });
      }
      setState(() {
        _error = e.toString();
      });
    }
    return false;
  }

  Future<void> _showReplyBottomSheet(Map<String, dynamic> feedback) async {
    log("message $feedback meow ${feedback['teacherDirectComment']}");
    if (feedback['teacherDirectComment'] is Map<String, dynamic>) {
      _replyController.text =
          feedback['teacherDirectComment']?['comment'] ?? '';
    } else {
      _replyController.clear(); // or set to default string
    }

    log("HERE");

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reply to 3Feedback',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _replyController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_replyController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a reply'),
                        ),
                      );
                      return;
                    }

                    try {
                      final user = ref.read(authProvider).user;
                      if (user == null) {
                        throw Exception('User not authenticated');
                      }

                      await _apiClient.post(
                        '/api/teacher/feedback/comment/teacher',
                        {
                          'comment': _replyController.text.trim(),
                          'ratingId': feedback['_id'],
                        },
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reply sent successfully'),
                          ),
                        );
                        _fetchTeacherData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Send Reply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final surfaceColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final accentColor = isDark ? Colors.blue[400]! : Colors.blue[600]!;
    final successColor = isDark ? Colors.green[400]! : Colors.green[600]!;
    final warningColor = isDark ? Colors.orange[400]! : Colors.orange[600]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Teachers',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Select a teacher to attach your account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mutedTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.80,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _teachersInList.length,
          itemBuilder: (context, index) {
            final teacher = _teachersInList[index];
            final isOnLeave = teacher['onLeave'] == true;
            final isAttached = teacher['userAttachedBool'] == true;

            return Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  if (isOnLeave || isAttached)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOnLeave
                            ? warningColor.withOpacity(0.1)
                            : successColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnLeave ? Icons.warning : Icons.check_circle,
                            size: 14,
                            color: isOnLeave ? warningColor : successColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnLeave ? 'On Leave' : 'Attached',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOnLeave ? warningColor : successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Teacher Image and Basic Info
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(
                        top: isOnLeave || isAttached
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                        bottom: const Radius.circular(0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: teacher['imageUrl'] != null
                                  ? NetworkImage(teacher['imageUrl'])
                                  : null,
                              child: teacher['imageUrl'] == null
                                  ? Icon(
                                      Icons.person,
                                      size: 20,
                                      color: mutedTextColor,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${teacher['rating']?.toStringAsFixed(1) ?? '0.0'}/5.0',
                          style: theme.textTheme.bodySmall,
                        )
                      ],
                    ),
                  ),

                  // Teacher Details
                  // Expanded(
                  // child:
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher['name'] ?? 'N/A',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          teacher['email'] ?? 'N/A',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: mutedTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _buildInfoRow(
                          Icons.school,
                          'Department',
                          teacher['department'] ?? 'N/A',
                          theme,
                          textColor,
                          mutedTextColor,
                        ),
                        // const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // ),
                  // Action Button
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: isAttached
                          ? null
                          : () => _handleTeacherSelect(teacher['_id']),
                      style: ElevatedButton.styleFrom(
                        // minimumSize: const Size(double.infinity, 20),
                        backgroundColor: isAttached
                            ? Colors.grey
                            : isOnLeave
                                ? warningColor
                                : accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isAttached
                            ? 'Already Attached'
                            : isOnLeave
                                ? 'Teacher on Leave'
                                : 'Request to Attach',
                        style: theme.textTheme.bodySmall?.copyWith(
                            // color: Colors.white,
                            // fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
    Color textColor,
    Color mutedTextColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                    // color: mutedTextColor,
                    ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                    // color: textColor,
                    // fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateTeacherButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person_add_outlined,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No existing teacher profile found?',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleCreateTeacherProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create Teacher Profile',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final surfaceColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final accentColor = isDark ? Colors.blue[400]! : Colors.blue[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Teacher Reviews',
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTeacherData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_message != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentColor),
                            ),
                            child: Text(
                              _message!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: textColor,
                              ),
                            ),
                          ),
                        if (_teacherData != null) ...[
                          // Teacher Profile Card
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          _teacherData?['imageUrl'] != null
                                              ? NetworkImage(
                                                  _teacherData!['imageUrl'])
                                              : null,
                                      child: _teacherData?['imageUrl'] == null
                                          ? Icon(
                                              Icons.person,
                                              size: 16,
                                              color: mutedTextColor,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _teacherData?['name'] ?? 'N/A',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _teacherData?['department']
                                                    ?['name'] ??
                                                'N/A',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: mutedTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (_teacherData?['rating']
                                                    ?.toString() ??
                                                '0.0'),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Feedbacks Section
                          Text(
                            'Student Feedbacks',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_feedbacks.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.feedback_outlined,
                                      size: 48,
                                      color: mutedTextColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No feedbacks yet',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Student feedbacks will appear here',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: mutedTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _feedbacks.length,
                              itemBuilder: (context, index) {
                                return _buildFeedbackItem(
                                  context,
                                  _feedbacks[index],
                                );
                              },
                            ),
                        ] else if (_teachersInList.isNotEmpty) ...[
                          _buildCreateTeacherButton(),
                          _buildTeacherList(),
                        ] else
                          _buildCreateTeacherButton(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFeedbackItem(
      BuildContext context, Map<String, dynamic> feedback) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    log("message ${feedback}");
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anonymous',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: List.generate(5, (starIndex) {
                  return Icon(
                    starIndex < (feedback['rating'] ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: starIndex < (feedback['rating'] ?? 0)
                        ? const Color(0xFFFFD700)
                        : mutedTextColor,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback['feedback'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feedback['updatedAt'] != null
                ? _formatDate(feedback['updatedAt'])
                : '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: mutedTextColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  toggleFavorite(feedback['_id']);
                },
                child: Icon(
                  feedback['favouritedByTeacher']
                      ? Icons.favorite
                      : Icons.favorite_outline_outlined,
                  color: feedback['favouritedByTeacher']
                      ? Colors.red
                      : mutedTextColor,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => {
                    // log("PRINTING $feedback"),
                    _showReplyBottomSheet(feedback)
                  },
                  child: Text(
                    feedback['teacherDirectComment'] != null &&
                            feedback['teacherDirectComment'].isNotEmpty
                        ? 'Edit Reply'
                        : 'Reply to Feedback',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (feedback['teacherDirectComment'] != null &&
              feedback['teacherDirectComment'].isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16,
                        color: mutedTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Your Reply',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(
                            feedback['teacherDirectComment']['createdAt']),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback['teacherDirectComment']['comment'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
