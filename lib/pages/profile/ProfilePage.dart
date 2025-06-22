import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/explore/page/SocietyPage.dart';
import 'package:socian/pages/home/widgets/components/post/post.dart';
import 'package:socian/pages/message/ChatPage.dart';
import 'package:socian/pages/profile/widgets/ConnectionsListPage.dart';
import 'package:socian/shared/services/api_client.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiClient = ApiClient();

  Map<String, dynamic>? _basicProfile;
  Map<String, dynamic>? _detailedProfile;
  List<dynamic> _posts = [];
  List<dynamic> _societies = [];
  List<dynamic> _moderatedSocieties = [];
  List<dynamic> _connections = [];
  List<dynamic> _uploadedPapers = [];
  File? _mediaFile;

  bool _isLoadingDetails = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBasicProfile();
    final auth = ref.read(authProvider);
    final isOwnProfile =
        widget.userId == null || widget.userId == auth.user?['_id'];
    _tabController = TabController(length: isOwnProfile ? 3 : 3, vsync: this);
    _fetchDetailedProfileData();
  }

  void _loadBasicProfile() {
    final auth = ref.read(authProvider);
    log('${auth.user}');

    final userId = widget.userId ?? auth.user?['_id'];

    if (userId == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    if (widget.userId == null || widget.userId == auth.user?['_id']) {
      setState(() {
        _basicProfile = {
          '_id': auth.user?['_id'],
          'name': auth.user?['name'],
          'username': auth.user?['username'],
          'joined': auth.user?['joined'],
          'profile': {
            'picture': auth.user?['profile']?['picture'],
            'bio': auth.user?['profile']?['bio'] ?? '',
          }
        };
      });
    }
  }

  Future<void> _fetchDetailedProfileData() async {
    setState(() {
      _isLoadingDetails = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authProvider);
      final userId = widget.userId ?? auth.user?['_id'];
      if (userId == null) {
        setState(() {
          _isLoadingDetails = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      // Handle each API call independently to prevent one failure from breaking the entire profile
      Map<String, dynamic>? profileResponse;
      Map<String, dynamic>? societiesResponse;
      List<dynamic>? moderatedSocietiesResponse;
      Map<String, dynamic>? connectionsResponse;
      Map<String, dynamic>? papersResponse;

      // Fetch profile data
      try {
        profileResponse = await _apiClient
            .get('/api/user/profile', queryParameters: {'id': userId});
      } catch (e) {
        debugPrint('Error fetching profile: $e');
      }

      // Fetch societies data
      try {
        societiesResponse = await _apiClient.get(
            '/api/user/subscribedSocieties',
            queryParameters: {'id': userId});
      } catch (e) {
        debugPrint('Error fetching societies: $e');
      }

      // Fetch moderated societies data
      try {
        moderatedSocietiesResponse = await _apiClient.get(
            '/api/user/moderated-societies',
            queryParameters: {'id': userId});
        debugPrint('Moderated societies response: $moderatedSocietiesResponse');
      } catch (e) {
        debugPrint('Error fetching moderated societies: $e');
      }

      // Fetch connections data
      try {
        connectionsResponse = await _apiClient
            .get('/api/user/connections', queryParameters: {'id': userId});
      } catch (e) {
        debugPrint('Error fetching connections: $e');
      }

      // Fetch papers data
      try {
        papersResponse = await _apiClient
            .get('/api/pastpaper/profile/papers?userId=$userId');
      } catch (e) {
        debugPrint('Error fetching papers: $e');
      }

      // Check if we have at least some profile data
      final hasProfileData = profileResponse != null &&
          !profileResponse.containsKey('error') &&
          profileResponse['profile'] != null;

      setState(() {
        // Set detailed profile if available
        if (hasProfileData) {
          _detailedProfile = profileResponse as Map<String, dynamic>;
          _posts = (_detailedProfile?['profile']['posts'] ?? [])
              .where((post) => post['author']['_id'] == userId)
              .toList();
        }

        // Set other data if available, otherwise use empty defaults
        _societies =
            (societiesResponse?['joinedSocieties'] as List<dynamic>?) ?? [];
        _moderatedSocieties = moderatedSocietiesResponse ?? [];
        _connections =
            (connectionsResponse?['connections'] as List<dynamic>?) ?? [];
        _uploadedPapers = (papersResponse?['data']?['profile']
                ?['papersUploaded'] as List<dynamic>?) ??
            [];

        // Log for debugging
        debugPrint('Subscribed societies: $_societies');
        debugPrint('Moderated societies: $_moderatedSocieties');

        // Update basic profile if detailed data is available
        if (hasProfileData) {
          _basicProfile ??= {
            '_id': _detailedProfile?['_id'],
            'name': _detailedProfile?['name'],
            'username': _detailedProfile?['username'],
            'joined': _detailedProfile?['joined'],
            'profile': {
              'picture': _detailedProfile?['profile']?['picture'],
              'bio': _detailedProfile?['profile']?['bio'] ?? '',
            }
          };
        }

        _isLoadingDetails = false;

        // Set error message only if no data could be loaded at all
        final auth = ref.read(authProvider);
        final isOwnProfile =
            widget.userId == null || widget.userId == auth.user?['_id'];

        if (!hasProfileData && !isOwnProfile) {
          _errorMessage = 'User not found';
        } else if (!hasProfileData && isOwnProfile) {
          _errorMessage = 'Some profile data could not be loaded';
        }
      });
    } catch (e) {
      debugPrint('Error in _fetchDetailedProfileData: $e');
      setState(() {
        _isLoadingDetails = false;
        final auth = ref.read(authProvider);
        final isOwnProfile =
            widget.userId == null || widget.userId == auth.user?['_id'];

        if (!isOwnProfile) {
          _errorMessage = 'Failed to load profile data';
        } else {
          _errorMessage = 'Some profile data could not be loaded';
        }
      });
    }
  }

  Future<void> _sendConnectRequest(String toUserId) async {
    try {
      final response = await _apiClient
          .post('/api/user/add-friend', {'toFriendUser': toUserId});
      debugPrint('sendConnectRequest: Response=$response');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      await _fetchDetailedProfileData();
    } catch (e) {
      debugPrint('sendConnectRequest: Error=$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send connection request')),
      );
    }
  }

  Future<void> _endConnection(String toUserId) async {
    try {
      final response = await _apiClient
          .post('/api/user/unfriend-request', {'toUn_FriendUser': toUserId});
      debugPrint('endConnection: Response=$response');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      await _fetchDetailedProfileData();
    } catch (e) {
      debugPrint('endConnection: Error=$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to end connection')),
      );
    }
  }

  Future<void> _handleRequest(String toUserId, String action) async {
    try {
      final endpoint = action == 'accept'
          ? '/api/user/accept-friend-request'
          : '/api/user/reject-friend-request';
      await _apiClient.post(endpoint, {
        action == 'accept' ? 'toAcceptFriendUser' : 'toRejectUser': toUserId,
      });
      debugPrint('$action: Response=Success for userId=$toUserId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${action}ed successfully')),
      );
      await _fetchDetailedProfileData();
    } catch (e) {
      debugPrint('$action: Error=$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to $action request')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to check if specific data is available
  bool _hasData(String dataType) {
    switch (dataType) {
      case 'posts':
        return _posts.isNotEmpty;
      case 'societies':
        return _societies.isNotEmpty || _moderatedSocieties.isNotEmpty;
      case 'papers':
        return _uploadedPapers.isNotEmpty;
      case 'connections':
        return _connections.isNotEmpty;
      default:
        return false;
    }
  }

  // Helper method to show partial loading state
  Widget _buildPartialLoadingState(String dataType, Color mutedForeground) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load $dataType',
            style: TextStyle(
              color: mutedForeground,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try refreshing the page',
            style: TextStyle(
              color: mutedForeground,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastPapersTab(Color background, Color foreground, Color border,
      Color mutedForeground, Color accent, Color primary) {
    if (_isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get the user's uploaded papers from the state
    final uploadedPapers = _uploadedPapers;

    // Check if we have papers data
    if (!_hasData('papers')) {
      // If we're not loading and have no papers, show appropriate message
      if (_detailedProfile == null) {
        return _buildPartialLoadingState('past papers', mutedForeground);
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No past papers uploaded yet',
              style: TextStyle(
                color: mutedForeground,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Papers you upload will appear here',
              style: TextStyle(
                color: mutedForeground,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: uploadedPapers.length,
      itemBuilder: (context, index) {
        final paper = uploadedPapers[index];
        final files = paper['files'] ?? [];

        return Card(
          color: accent,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Paper header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        paper['type'] ?? 'Unknown Type',
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        paper['category'] ?? 'Unknown Category',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Paper name
                Text(
                  paper['name'] ?? 'Untitled Paper',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Paper details
                Row(
                  children: [
                    Icon(Icons.school, color: mutedForeground, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Term: ${paper['term'] ?? 'Unknown'}',
                      style: TextStyle(color: mutedForeground, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today,
                        color: mutedForeground, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Year: ${paper['academicYear'] ?? 'Unknown'}',
                      style: TextStyle(color: mutedForeground, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Files count
                Row(
                  children: [
                    Icon(Icons.attach_file, color: mutedForeground, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${files.length} file${files.length != 1 ? 's' : ''} uploaded',
                      style: TextStyle(color: mutedForeground, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metadata
                if (paper['metadata'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetadataItem(
                          'Views',
                          paper['metadata']['views']?.toString() ?? '0',
                          Icons.visibility,
                          mutedForeground,
                        ),
                        _buildMetadataItem(
                          'Downloads',
                          paper['metadata']['downloads']?.toString() ?? '0',
                          Icons.download,
                          mutedForeground,
                        ),
                        _buildMetadataItem(
                          'Answers',
                          paper['metadata']['answers']?.toString() ?? '0',
                          Icons.question_answer,
                          mutedForeground,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Files list
                if (files.isNotEmpty) ...[
                  Text(
                    'Uploaded Files:',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...files
                      .map<Widget>((file) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'File ${files.indexOf(file) + 1}',
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Uploaded: ${_formatDate(file['uploadedAt'])}',
                                        style: TextStyle(
                                          color: mutedForeground,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (file['teachers'] != null &&
                                    file['teachers'].isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${file['teachers'].length} teacher${file['teachers'].length != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                ],

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to discussion view
                          Navigator.pushNamed(
                            context,
                            AppRoutes.discussionViewScreen,
                            arguments: {
                              '_id': paper['_id'],
                              'paperType': paper['type'],
                              'subjectId': paper['subjectId'],
                            },
                          );
                        },
                        icon: const Icon(Icons.forum, size: 16),
                        label: const Text('View Discussion'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // Show paper details
                        _showPaperDetails(paper);
                      },
                      icon: Icon(Icons.info_outline, color: primary),
                      tooltip: 'View Details',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void _showPaperDetails(Map<String, dynamic> paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paper Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${paper['name'] ?? 'Unknown'}'),
              Text('Type: ${paper['type'] ?? 'Unknown'}'),
              Text('Category: ${paper['category'] ?? 'Unknown'}'),
              Text('Term: ${paper['term'] ?? 'Unknown'}'),
              Text('Academic Year: ${paper['academicYear'] ?? 'Unknown'}'),
              if (paper['metadata'] != null) ...[
                const SizedBox(height: 16),
                const Text('Statistics:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Views: ${paper['metadata']['views'] ?? 0}'),
                Text('Downloads: ${paper['metadata']['downloads'] ?? 0}'),
                Text('Answers: ${paper['metadata']['answers'] ?? 0}'),
                Text(
                    'Total Questions: ${paper['metadata']['totalQuestions'] ?? 0}'),
                Text(
                    'Answered Questions: ${paper['metadata']['answeredQuestions'] ?? 0}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(Color background, Color foreground, Color border,
      Color mutedForeground, Color accent) {
    if (_isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if we have posts data
    if (!_hasData('posts')) {
      // If we're not loading and have no posts, show appropriate message
      if (_detailedProfile == null) {
        return _buildPartialLoadingState('posts', mutedForeground);
      }
      return Center(
          child:
              Text('No posts yet', style: TextStyle(color: mutedForeground)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return PostCard(
          post: post,
          flairType: Flairs.campus.value,
        );
      },
    );
  }

  Widget _buildSocietyTab(Color background, Color foreground, Color border,
      Color mutedForeground, Color accent, Color primary) {
    if (_isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create a map to merge societies, prioritizing moderated ones
    final societyMap = <String, Map<String, dynamic>>{};

    // First, add all subscribed societies
    for (var society in _societies) {
      societyMap[society['_id']] = {
        ...society,
        'isModerated': false,
      };
    }

    // Then, update or add moderated societies
    for (var society in _moderatedSocieties) {
      societyMap[society['_id']] = {
        ...society,
        'isModerated': true,
      };
    }

    final allSocieties = societyMap.values.toList();

    // Check if we have societies data
    if (!_hasData('societies')) {
      // If we're not loading and have no societies, show appropriate message
      if (_detailedProfile == null) {
        return _buildPartialLoadingState('societies', mutedForeground);
      }
      return Center(
          child: Text('No societies joined',
              style: TextStyle(color: mutedForeground)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: allSocieties.length,
      itemBuilder: (context, index) {
        final society = allSocieties[index];
        final memberCount = society['totalMembers']?.toString() ?? '0';
        final isModerated = society['isModerated'] ?? false;
        return Card(
          color: accent,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SocietyPage(
                              societyId: society['_id'],
                            ),
                          ),
                        );
                      },
                      child: Text(
                        society['name'] ?? 'Unknown Society',
                        style: TextStyle(
                          color: foreground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (isModerated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Moderator',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$memberCount members',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  society['description'] ?? '',
                  style: TextStyle(color: mutedForeground),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectButton(String userId, Color primary, Color foreground) {
    final friendStatus = _detailedProfile?['friendStatus'] ?? 'connect';
    bool isDisabled = false;
    String buttonText = 'Connect';
    VoidCallback? onPressed = () => _sendConnectRequest(userId);

    switch (friendStatus) {
      case 'friends':
        buttonText = 'End Connection';
        onPressed = () => _endConnection(userId);
        break;
      case 'canCancel':
        buttonText = 'Already sent';
        isDisabled = true;
        onPressed = null;
        break;
      case 'accept/reject':
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _handleRequest(userId, 'accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _handleRequest(userId, 'reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      case 'connect':
      default:
        buttonText = 'Connect';
        onPressed = () => _sendConnectRequest(userId);
        break;
    }

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(buttonText),
      ),
    );
  }

  Future<void> uploadProfilePicture() async {
    if (_mediaFile == null) {
      debugPrint("uploadProfilePicture: No media file selected");
      return;
    }
    try {
      final data = <String, dynamic>{'file': ''};

      data['file'] = await MultipartFile.fromFile(
        _mediaFile!.path,
        filename:
            '${DateTime.now().millisecondsSinceEpoch}_${_mediaFile!.path.split('/').last}',
        contentType: MediaType.parse('image/jpeg'),
      );

      final response =
          await _apiClient.putFormData(ApiConstants.uploadProfilePic, data);
      debugPrint("Profile pic response $response");
      await _fetchDetailedProfileData();
    } catch (e) {
      debugPrint("uploadProfilePicture: Error=$e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    const primary = Color(0xFF8B5CF6);

    if (_errorMessage != null) {
      final isOwnProfile =
          widget.userId == null || widget.userId == auth.user?['_id'];

      // For own profile, continue to show basic profile even with error
      if (isOwnProfile && _basicProfile != null) {
        // Continue to show the profile, error will be handled in the UI
      } else {
        // For other users' profiles, show error screen
        return Scaffold(
          backgroundColor: background,
          body: Center(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: mutedForeground),
            ),
          ),
        );
      }
    }

    if (_basicProfile == null) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isOwnProfile =
        widget.userId == null || widget.userId == auth.user?['_id'];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: isOwnProfile ? false : true,
        backgroundColor: background,
        elevation: 0,
        actions: [
          if (isOwnProfile) ...[
            IconButton(
              icon: Icon(Icons.refresh, color: foreground),
              onPressed:
                  _isLoadingDetails ? null : () => _fetchDetailedProfileData(),
              tooltip: 'Refresh profile data',
            ),
            IconButton(
              icon: Icon(Icons.more_horiz, color: foreground),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _basicProfile?['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '@${_basicProfile?['username'] ?? 'unknown'}',
                                style: TextStyle(
                                    color: mutedForeground, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: accent,
                            backgroundImage:
                                _basicProfile?['profile']?['picture'] != null
                                    ? NetworkImage(
                                        _basicProfile!['profile']['picture'])
                                    : const AssetImage(
                                            "assets/images/profilepic2.jpg")
                                        as ImageProvider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: mutedForeground, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Joined ${_basicProfile?['joined'] ?? 'Unknown'}',
                          style: TextStyle(color: mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          auth.user?['university']?['campusId']?['name'] ??
                              'Unknown Campus',
                          style: TextStyle(color: mutedForeground),
                        ),
                        Text(
                          ' - ${auth.user?['university']?['departmentId']?['name'] ?? 'Unknown Department'}',
                          style: TextStyle(color: mutedForeground),
                        ),
                      ],
                    ),
                    Text(
                      auth.user?['role'] ?? 'Unknown Role',
                      style: TextStyle(color: mutedForeground),
                    ),
                    if (_basicProfile?['profile']['bio']?.isNotEmpty ??
                        false) ...[
                      const SizedBox(height: 16),
                      Text(
                        _basicProfile!['profile']['bio'],
                        style: TextStyle(color: mutedForeground),
                      ),
                    ],
                    // Show error indicator for own profile when there's an error
                    if (_errorMessage != null && isOwnProfile) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _isLoadingDetails
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: isOwnProfile
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ConnectionsListPage()),
                                        )
                                    : null,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${_connections.length} ',
                                        style: TextStyle(
                                          color: foreground,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Connections',
                                        style: TextStyle(
                                          color: mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isOwnProfile)
                                IconButton(
                                  icon: Icon(Icons.message, color: foreground),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        userId: _basicProfile!['_id'],
                                        userName: _basicProfile!['name'],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    if (!isOwnProfile && !_isLoadingDetails) ...[
                      const SizedBox(height: 16),
                      _buildConnectButton(
                          _basicProfile!['_id'], primary, foreground),
                    ],
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: foreground,
                  unselectedLabelColor: mutedForeground,
                  indicatorColor: primary,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Societies'),
                    Tab(text: 'Past Papers'),
                  ],
                ),
                background,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(
                background, foreground, border, mutedForeground, accent),
            _buildSocietyTab(background, foreground, border, mutedForeground,
                accent, primary),
            _buildPastPapersTab(background, foreground, border, mutedForeground,
                accent, primary),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _background;

  _SliverAppBarDelegate(this._tabBar, this._background);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}