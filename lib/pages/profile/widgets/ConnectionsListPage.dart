import 'package:beyondtheclass/pages/profile/ProfilePage.dart';
// import 'package:beyondtheclass/pages/profile/profile_page.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionsListPage extends ConsumerStatefulWidget {
  const ConnectionsListPage({super.key});

  @override
  _ConnectionsListPageState createState() => _ConnectionsListPageState();
}

class _ConnectionsListPageState extends ConsumerState<ConnectionsListPage> {
  final _apiClient = ApiClient();
  List<dynamic> _connections = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConnections();
  }

  Future<void> _fetchConnections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get('/api/user/connections');
      setState(() {
        _connections = response['connections'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      String errorMsg = 'Failed to load connections';
      if (e is dio.DioException) {
        errorMsg += ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
        debugPrint('Dio error fetching connections: $errorMsg');
      } else {
        debugPrint('Unexpected error fetching connections: $e');
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
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
      await _fetchConnections();
    } catch (e) {
      debugPrint('endConnection: Error=$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to end connection')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    const primary = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: Text(
          'Connections',
          style: TextStyle(
            color: foreground,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
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
                      padding: const EdgeInsets.all(16),
                      itemCount: _connections.length,
                      itemBuilder: (context, index) {
                        final connection = _connections[index];
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilePage(
                                          userId: connection['_id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        connection['picture'] != null
                                            ? NetworkImage(connection['picture'])
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
                                              builder: (context) => ProfilePage(
                                                userId: connection['_id'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          connection['name'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: foreground,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '@${connection['username'] ?? 'unknown'}',
                                        style: TextStyle(
                                          color: mutedForeground,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _endConnection(connection['_id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('End Connection'),
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
    );
  }
}