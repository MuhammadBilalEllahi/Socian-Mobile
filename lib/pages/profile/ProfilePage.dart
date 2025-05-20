// import 'dart:developer';
// import 'dart:io';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:beyondtheclass/pages/home/widgets/components/post/post.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:http_parser/http_parser.dart';

// class ProfilePage extends ConsumerStatefulWidget {
//   final String? userId;

//   const ProfilePage({super.key, this.userId});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends ConsumerState<ProfilePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final _apiClient = ApiClient();

//   Map<String, dynamic>? _basicProfile;
//   Map<String, dynamic>? _detailedProfile;
//   List<dynamic> _posts = [];
//   List<dynamic> _societies = [];
//   List<dynamic> _connections = [];
//   late File _mediaFile;

//   bool _isLoadingDetails = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadBasicProfile();
//     final auth = ref.read(authProvider);
//     final isOwnProfile =
//         widget.userId == null || widget.userId == auth.user?['_id'];
//     _tabController = TabController(length: isOwnProfile ? 2 : 2, vsync: this);
//     _fetchDetailedProfileData();
//   }

//   void _loadBasicProfile() {
//     final auth = ref.read(authProvider);
//     log('${auth.user}');

//     final userId = widget.userId ?? auth.user?['_id'];

//     if (userId == null) {
//       setState(() {
//         _errorMessage = 'User not logged in';
//       });
//       return;
//     }

//     if (widget.userId == null || widget.userId == auth.user?['_id']) {
//       setState(() {
//         _basicProfile = {
//           '_id': auth.user?['_id'],
//           'name': auth.user?['name'],
//           'username': auth.user?['username'],
//           'joined': auth.user?['joined'],
//           'profile': {
//             'picture': auth.user?['profile']?['picture'],
//             'bio': auth.user?['profile']?['bio'] ?? '',
//           }
//         };
//       });
//     }
//   }

//   Future<void> _fetchDetailedProfileData() async {
//     setState(() {
//       _isLoadingDetails = true;
//       _errorMessage = null;
//     });

//     try {
//       final auth = ref.read(authProvider);
//       final userId = widget.userId ?? auth.user?['_id'];
//       if (userId == null) {
//         setState(() {
//           _isLoadingDetails = false;
//           _errorMessage = 'User not logged in';
//         });
//         return;
//       }

//       final results = await Future.wait([
//         _apiClient.get('/api/user/profile', queryParameters: {'id': userId}),
//         _apiClient.get('/api/user/subscribedSocieties',
//             queryParameters: {'id': userId}),
//         _apiClient.get('/api/user/connections', queryParameters: {'id': userId}),
//       ]);

//       final profileResponse = results[0];
//       final societiesResponse = results[1];
//       final connectionsResponse = results[2];

//       if (profileResponse.containsKey('error') ||
//           profileResponse['profile'] == null) {
//         setState(() {
//           _isLoadingDetails = false;
//           _errorMessage = profileResponse['error'] ?? 'User not found';
//         });
//         return;
//       }

//       setState(() {
//         _detailedProfile = profileResponse as Map<String, dynamic>;
//         _posts = (_detailedProfile?['profile']['posts'] ?? [])
//             .where((post) => post['author']['_id'] == userId)
//             .toList();
//         _societies = societiesResponse['joinedSocieties'] ?? [];
//         _connections = connectionsResponse['connections'] ?? [];

//         if (_basicProfile == null) {
//           _basicProfile = {
//             '_id': _detailedProfile?['_id'],
//             'name': _detailedProfile?['name'],
//             'username': _detailedProfile?['username'],
//             'joined': _detailedProfile?['joined'],
//             'profile': {
//               'picture': _detailedProfile?['profile']?['picture'],
//               'bio': _detailedProfile?['profile']?['bio'] ?? '',
//             }
//           };
//         }

//         _isLoadingDetails = false;
//       });
//     } catch (e) {
//       debugPrint('Error fetching profile data: $e');
//       setState(() {
//         _isLoadingDetails = false;
//         _errorMessage = 'Failed to load some profile data';
//       });
//     }
//   }

//   Future<void> _sendConnectRequest(String toUserId) async {
//     try {
//       final response =
//           await _apiClient.post('/api/user/add-friend', {'toFriendUser': toUserId});
//       debugPrint('sendConnectRequest: Response=$response');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response['message'])),
//       );
//       await _fetchDetailedProfileData();
//     } catch (e) {
//       debugPrint('sendConnectRequest: Error=$e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to send connection request')),
//       );
//     }
//   }

//   Future<void> _endConnection(String toUserId) async {
//     try {
//       final response = await _apiClient
//           .post('/api/user/unfriend-request', {'toUn_FriendUser': toUserId});
//       debugPrint('endConnection: Response=$response');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response['message'])),
//       );
//       await _fetchDetailedProfileData();
//     } catch (e) {
//       debugPrint('endConnection: Error=$e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to end connection')),
//       );
//     }
//   }

//   Future<void> _handleRequest(String toUserId, String action) async {
//     try {
//       final endpoint = action == 'accept'
//           ? '/api/user/accept-friend-request'
//           : '/api/user/reject-friend-request';
//       await _apiClient.post(endpoint, {
//         action == 'accept' ? 'toAcceptFriendUser' : 'toRejectUser': toUserId,
//       });
//       debugPrint('$action: Response=Success for userId=$toUserId');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Request ${action}ed successfully')),
//       );
//       await _fetchDetailedProfileData();
//     } catch (e) {
//       debugPrint('$action: Error=$e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to $action request')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Widget _buildPostsTab(Color background, Color foreground, Color border,
//       Color mutedForeground, Color accent) {
//     if (_isLoadingDetails) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_posts.isEmpty) {
//       return Center(
//           child:
//               Text('No posts yet', style: TextStyle(color: mutedForeground)));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: _posts.length,
//       itemBuilder: (context, index) {
//         final post = _posts[index];
//         return PostCard(
//           post: post,
//           flairType: Flairs.campus.value,
//         );
//       },
//     );
//   }

//   Widget _buildSocietyTab(Color background, Color foreground, Color border,
//       Color mutedForeground, Color accent, Color primary) {
//     if (_isLoadingDetails) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_societies.isEmpty) {
//       return Center(
//           child: Text('No societies joined',
//               style: TextStyle(color: mutedForeground)));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: _societies.length,
//       itemBuilder: (context, index) {
//         final society = _societies[index];
//         return Card(
//           color: accent,
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: border),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       society["name"],
//                       style: TextStyle(
//                         color: foreground,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: primary,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '250 members',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text('A community for enthusiasts.',
//                     style: TextStyle(color: mutedForeground)),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Activities:',
//                   style: TextStyle(
//                     color: foreground,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: ['Events', 'Workshops']
//                       .map((activity) => Chip(
//                             label: Text(
//                               activity,
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                             backgroundColor: Colors.grey[800],
//                             labelStyle: const TextStyle(color: Colors.white),
//                           ))
//                       .toList(),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Benefits:',
//                   style: TextStyle(
//                     color: foreground,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: ['Networking', 'Skills']
//                       .map((benefit) => Chip(
//                             label: Text(
//                               benefit,
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                             backgroundColor: Colors.green[900],
//                             labelStyle: const TextStyle(color: Colors.white),
//                           ))
//                       .toList(),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle join/leave society
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primary,
//                     minimumSize: const Size(double.infinity, 40),
//                   ),
//                   child: const Text('View Society'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildConnectButton(String userId, Color primary, Color foreground) {
//     final friendStatus = _detailedProfile?['friendStatus'] ?? 'connect';
//     bool isDisabled = false;
//     String buttonText = 'Connect';
//     VoidCallback? onPressed = () => _sendConnectRequest(userId);

//     switch (friendStatus) {
//       case 'friends':
//         buttonText = 'End Connection';
//         onPressed = () => _endConnection(userId);
//         break;
//       case 'canCancel':
//         buttonText = 'Already sent';
//         isDisabled = true;
//         onPressed = null;
//         break;
//       case 'accept/reject':
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             ElevatedButton(
//               onPressed: () => _handleRequest(userId, 'accept'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Accept'),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () => _handleRequest(userId, 'reject'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Reject'),
//             ),
//           ],
//         );
//       case 'connect':
//       default:
//         buttonText = 'Connect';
//         onPressed = () => _sendConnectRequest(userId);
//         break;
//     }

//     return Opacity(
//       opacity: isDisabled ? 0.5 : 1.0,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primary,
//           foregroundColor: foreground,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(buttonText),
//       ),
//     );
//   }

//   Future<void> uploadProfilePicture() async {
//     try {
//       final data = <String, dynamic>{'file': ''};

//       if (_mediaFile != null) {
//         data['file'] = await MultipartFile.fromFile(
//           _mediaFile.path,
//           filename:
//               '${DateTime.now().millisecondsSinceEpoch}_${_mediaFile.path.split('/').last}',
//           contentType: MediaType.parse('image/jpeg'),
//         );
//       }

//       final response =
//           await _apiClient.putFormData(ApiConstants.uploadProfilePic, data);
//       debugPrint("Profile pic response $response");
//     } catch (e) {
//       debugPrint("uploadProfilePicture: Error=$e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authProvider);
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted =
//         isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground =
//         isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border =
//         isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent =
//         isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
//     const primary = Color(0xFF8B5CF6);

//     if (_errorMessage != null) {
//       return Scaffold(
//         backgroundColor: background,
//         body: Center(
//           child: Text(
//             _errorMessage!,
//             style: TextStyle(color: mutedForeground),
//           ),
//         ),
//       );
//     }

//     if (_basicProfile == null) {
//       return Scaffold(
//         backgroundColor: background,
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final isOwnProfile =
//         widget.userId == null || widget.userId == auth.user?['_id'];

//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: background,
//         elevation: 0,
//         actions: [
//           if (isOwnProfile)
//             IconButton(
//               icon: Icon(Icons.more_horiz, color: foreground),
//               onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
//             ),
//         ],
//       ),
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _basicProfile?['name'] ?? 'Unknown',
//                                 style: TextStyle(
//                                   color: foreground,
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Text(
//                                 '@${_basicProfile?['username'] ?? 'unknown'}',
//                                 style: TextStyle(
//                                     color: mutedForeground, fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: primary,
//                               width: 2,
//                             ),
//                           ),
//                           child: CircleAvatar(
//                             radius: 30,
//                             backgroundColor: accent,
//                             backgroundImage:
//                                 _basicProfile?['profile']?['picture'] != null
//                                     ? NetworkImage(
//                                         _basicProfile!['profile']['picture'])
//                                     : const AssetImage(
//                                             "assets/images/profilepic2.jpg")
//                                         as ImageProvider,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Icon(Icons.calendar_today,
//                             color: mutedForeground, size: 16),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Joined ${_basicProfile?['joined'] ?? 'Unknown'}',
//                           style: TextStyle(color: mutedForeground),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Text(
//                           '${auth.user?['university']['campusId']['name']}',
//                           style: TextStyle(color: mutedForeground),
//                         ),
//                         Text(
//                           ' - ${auth.user?['university']['departmentId']['name']}',
//                           style: TextStyle(color: mutedForeground),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       '${auth.user?['role']}',
//                       style: TextStyle(color: mutedForeground),
//                     ),
//                     if (_basicProfile?['profile']['bio']?.isNotEmpty ??
//                         false) ...[
//                       const SizedBox(height: 16),
//                       Text(
//                         _basicProfile!['profile']['bio'],
//                         style: TextStyle(color: mutedForeground),
//                       ),
//                     ],
//                     const SizedBox(height: 16),
//                     _isLoadingDetails
//                         ? const CircularProgressIndicator()
//                         : RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: '${_connections.length} ',
//                                   style: TextStyle(
//                                     color: foreground,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: 'Connections',
//                                   style: TextStyle(color: mutedForeground),
//                                 ),
//                               ],
//                             ),
//                           ),
//                     if (!isOwnProfile && !_isLoadingDetails) ...[
//                       const SizedBox(height: 16),
//                       _buildConnectButton(
//                           _basicProfile!['_id'], primary, foreground),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _SliverAppBarDelegate(
//                 TabBar(
//                   controller: _tabController,
//                   isScrollable: true,
//                   labelColor: foreground,
//                   unselectedLabelColor: mutedForeground,
//                   indicatorColor: primary,
//                   tabs: [
//                     const Tab(text: 'Posts'),
//                     const Tab(text: 'Societies'),
//                   ],
//                 ),
//                 background,
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildPostsTab(
//                 background, foreground, border, mutedForeground, accent),
//             _buildSocietyTab(background, foreground, border, mutedForeground,
//                 accent, primary),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;
//   final Color _background;

//   _SliverAppBarDelegate(this._tabBar, this._background);

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: _background,
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }



















import 'dart:developer';
import 'dart:io';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/home/widgets/components/post/post.dart';
import 'package:beyondtheclass/pages/profile/widgets/ConnectionsListPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:http_parser/http_parser.dart';

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
  List<dynamic> _connections = [];
  late File _mediaFile;

  bool _isLoadingDetails = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBasicProfile();
    final auth = ref.read(authProvider);
    final isOwnProfile =
        widget.userId == null || widget.userId == auth.user?['_id'];
    _tabController = TabController(length: isOwnProfile ? 2 : 2, vsync: this);
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

      final results = await Future.wait([
        _apiClient.get('/api/user/profile', queryParameters: {'id': userId}),
        _apiClient.get('/api/user/subscribedSocieties',
            queryParameters: {'id': userId}),
        _apiClient.get('/api/user/connections', queryParameters: {'id': userId}),
      ]);

      final profileResponse = results[0];
      final societiesResponse = results[1];
      final connectionsResponse = results[2];

      if (profileResponse.containsKey('error') ||
          profileResponse['profile'] == null) {
        setState(() {
          _isLoadingDetails = false;
          _errorMessage = profileResponse['error'] ?? 'User not found';
        });
        return;
      }

      setState(() {
        _detailedProfile = profileResponse as Map<String, dynamic>;
        _posts = (_detailedProfile?['profile']['posts'] ?? [])
            .where((post) => post['author']['_id'] == userId)
            .toList();
        _societies = societiesResponse['joinedSocieties'] ?? [];
        _connections = connectionsResponse['connections'] ?? [];

        if (_basicProfile == null) {
          _basicProfile = {
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
      });
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      setState(() {
        _isLoadingDetails = false;
        _errorMessage = 'Failed to load some profile data';
      });
    }
  }

  Future<void> _sendConnectRequest(String toUserId) async {
    try {
      final response =
          await _apiClient.post('/api/user/add-friend', {'toFriendUser': toUserId});
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

  Widget _buildPostsTab(Color background, Color foreground, Color border,
      Color mutedForeground, Color accent) {
    if (_isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posts.isEmpty) {
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
    if (_societies.isEmpty) {
      return Center(
          child: Text('No societies joined',
              style: TextStyle(color: mutedForeground)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _societies.length,
      itemBuilder: (context, index) {
        final society = _societies[index];
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
                    Text(
                      society["name"],
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '250 members',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('A community for enthusiasts.',
                    style: TextStyle(color: mutedForeground)),
                const SizedBox(height: 16),
                Text(
                  'Activities:',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Events', 'Workshops']
                      .map((activity) => Chip(
                            label: Text(
                              activity,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.grey[800],
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Benefits:',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Networking', 'Skills']
                      .map((benefit) => Chip(
                            label: Text(
                              benefit,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.green[900],
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle join/leave society
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('View Society'),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    try {
      final data = <String, dynamic>{'file': ''};

      if (_mediaFile != null) {
        data['file'] = await MultipartFile.fromFile(
          _mediaFile.path,
          filename:
              '${DateTime.now().millisecondsSinceEpoch}_${_mediaFile.path.split('/').last}',
          contentType: MediaType.parse('image/jpeg'),
        );
      }

      final response =
          await _apiClient.putFormData(ApiConstants.uploadProfilePic, data);
      debugPrint("Profile pic response $response");
    } catch (e) {
      debugPrint("uploadProfilePicture: Error=$e");
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
        backgroundColor: background,
        elevation: 0,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: Icon(Icons.more_horiz, color: foreground),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
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
                          '${auth.user?['university']['campusId']['name']}',
                          style: TextStyle(color: mutedForeground),
                        ),
                        Text(
                          ' - ${auth.user?['university']['departmentId']['name']}',
                          style: TextStyle(color: mutedForeground),
                        ),
                      ],
                    ),
                    Text(
                      '${auth.user?['role']}',
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
                    const SizedBox(height: 16),
                    _isLoadingDetails
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: isOwnProfile
                                ? () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ConnectionsListPage()),
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
                                      decoration: isOwnProfile
                                          ? TextDecoration.underline
                                          : null,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Connections',
                                    style: TextStyle(
                                      color: mutedForeground,
                                      decoration: isOwnProfile
                                          ? TextDecoration.underline
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                  tabs: [
                    const Tab(text: 'Posts'),
                    const Tab(text: 'Societies'),
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