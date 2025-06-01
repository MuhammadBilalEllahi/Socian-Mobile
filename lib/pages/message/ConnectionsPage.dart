import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socian/pages/message/ChatPage.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';

class ConnectionsPage extends ConsumerStatefulWidget {
  const ConnectionsPage({super.key});

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends ConsumerState<ConnectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiClient = ApiClient();

  List _requests = [];
  List _connections = [];
  bool _isLoadingRequests = true;
  bool _isLoadingConnections = true;
  String? _errorMessageRequests;
  String? _errorMessageConnections;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchFriendRequests();
    _fetchConnections();
  }

  Future _fetchFriendRequests() async {
    setState(() {
      _isLoadingRequests = true;
      _errorMessageRequests = null;
    });

    try {
      final response = await _apiClient.get('/api/user/friend-requests');
      setState(() {
        _requests = response['requests'] ?? [];
        _isLoadingRequests = false;
      });
    } catch (e) {
      String errorMsg = 'Failed to load connection requests';
      if (e is dio.DioException) {
        errorMsg +=
            ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
        debugPrint('Dio error fetching friend requests: $errorMsg');
      } else {
        debugPrint('Unexpected error fetching friend requests: $e');
      }
      setState(() {
        _errorMessageRequests = errorMsg;
        _isLoadingRequests = false;
      });
    }
  }

  Future _fetchConnections() async {
    setState(() {
      _isLoadingConnections = true;
      _errorMessageConnections = null;
    });

    try {
      final response = await _apiClient.get('/api/user/connections');
      setState(() {
        _connections = response['connections'] ?? [];
        _isLoadingConnections = false;
      });
    } catch (e) {
      String errorMsg = 'Failed to load connections';
      if (e is dio.DioException) {
        errorMsg +=
            ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
        debugPrint('Dio error fetching connections: $errorMsg');
      } else {
        debugPrint('Unexpected error fetching connections: $e');
      }
      setState(() {
        _errorMessageConnections = errorMsg;
        _isLoadingConnections = false;
      });
    }
  }

  Future _handleRequest(String toUserId, String action) async {
    try {
      final endpoint = action == 'accept'
          ? '/api/user/accept-friend-request'
          : '/api/user/reject-friend-request';

      await _apiClient.post(endpoint, {
        action == 'accept' ? 'toAcceptFriendUser' : 'toRejectUser': toUserId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${action}ed successfully')),
      );

      await _fetchFriendRequests();
      await _fetchConnections();
    } catch (e) {
      debugPrint('Error $action request: $e');
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

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: background,
                title: Text(
                  'Connections',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                pinned: true,
                floating: true,
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: foreground,
                  unselectedLabelColor: mutedForeground,
                  indicatorColor: primary,
                  tabs: const [
                    Tab(text: 'Messages'),
                    Tab(text: 'Something'),
                    Tab(text: 'Requests'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Messages Tab
              _isLoadingConnections
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessageConnections != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessageConnections!,
                                style: TextStyle(color: mutedForeground),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchConnections,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: foreground,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _connections.isEmpty
                          ? Center(
                              child: Text(
                                'No connections yet',
                                style: TextStyle(color: mutedForeground),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _connections.length,
                              itemBuilder: (context, index) {
                                final connection = _connections[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          userId: connection['_id'],
                                          userName:
                                              connection['name'] ?? 'Unknown',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: connection[
                                                      'picture'] !=
                                                  null
                                              ? NetworkImage(
                                                  connection['picture'])
                                              : const AssetImage(
                                                      'assets/images/profilepic2.jpg')
                                                  as ImageProvider,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                connection['name'] ?? 'Unknown',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: foreground,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '@${connection['username'] ?? 'unknown'}',
                                                style: TextStyle(
                                                  color: mutedForeground,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

              // Something Tab
              Center(
                child: Text(
                  'Something (Not Implemented)',
                  style: TextStyle(color: mutedForeground),
                ),
              ),

              // Connection Requests Tab
              _isLoadingRequests
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessageRequests != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessageRequests!,
                                style: TextStyle(color: mutedForeground),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchFriendRequests,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: foreground,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _requests.isEmpty
                          ? Center(
                              child: Text(
                                'No pending connection requests',
                                style: TextStyle(color: mutedForeground),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];
                                final createdAt =
                                    DateTime.parse(request['createdAt']);
                                final formattedDate =
                                    DateFormat('MMM d, y').format(createdAt);
                                final fromUser = request['fromUser'];
                                final screenWidth =
                                    MediaQuery.of(context).size.width;

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: accent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage(
                                                  userId: fromUser['_id'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: fromUser[
                                                        'profilePicture'] !=
                                                    null
                                                ? NetworkImage(
                                                    fromUser['profilePicture'])
                                                : const AssetImage(
                                                        'assets/images/profilepic2.jpg')
                                                    as ImageProvider,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfilePage(
                                                        userId: fromUser['_id'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  fromUser['name'] ?? 'Unknown',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: foreground,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '@${fromUser['username'] ?? 'unknown'}',
                                                style: TextStyle(
                                                  color: mutedForeground,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Sent on $formattedDate',
                                                style: TextStyle(
                                                  color: mutedForeground,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 8,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth > 350
                                                        ? 100
                                                        : double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () =>
                                                          _handleRequest(
                                                              fromUser['_id'],
                                                              'accept'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            primary,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child:
                                                          const Text('Accept'),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth > 350
                                                        ? 100
                                                        : double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () =>
                                                          _handleRequest(
                                                              fromUser['_id'],
                                                              'reject'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child:
                                                          const Text('Reject'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ],
          ),
        ),
      ),
    );
  }
}
