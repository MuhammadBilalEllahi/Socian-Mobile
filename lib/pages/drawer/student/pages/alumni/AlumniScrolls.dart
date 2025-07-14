import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';

class AlumniScrolls extends StatefulWidget {
  const AlumniScrolls({super.key});

  @override
  State<AlumniScrolls> createState() => _AlumniScrollsState();
}

class _AlumniScrollsState extends State<AlumniScrolls> {
  final _apiClient = ApiClient();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _filteredPeople = [];
  String _searchQuery = '';
  String _selectedRole = 'Alumni';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  // Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;
  static const int _pageSize = 10;

  final List<String> roles = ['Alumni', 'Student', 'Teacher'];

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadUsers();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasNextPage) {
          _loadMoreUsers();
        }
      }
    });
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      if (refresh) {
        _filteredPeople.clear();
        _currentPage = 1;
        _hasNextPage = true;
      }
    });

    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        // if (_selectedRole.toLowerCase() != 'alumni')
        'role': _selectedRole.toLowerCase(),
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final response = await _apiClient.get(
        // '/api/user/campus-users',
        '/api/user/all-users2',
        queryParameters: queryParams,
      );

      final users = List<Map<String, dynamic>>.from(response['users'] ?? []);
      final pagination = response['pagination'] ?? {};

      setState(() {
        if (refresh || _currentPage == 1) {
          _filteredPeople = users;
        } else {
          _filteredPeople.addAll(users);
        }
        _hasNextPage = pagination['hasNextPage'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading users: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load campus users';
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;

    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        if (_selectedRole.toLowerCase() != 'alumni')
          'role': _selectedRole.toLowerCase(),
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final response = await _apiClient.get(
        // '/api/user/campus-users',
        '/api/user/all-users2',
        queryParameters: queryParams,
      );

      final users = List<Map<String, dynamic>>.from(response['users'] ?? []);
      final pagination = response['pagination'] ?? {};

      setState(() {
        _filteredPeople.addAll(users);
        _hasNextPage = pagination['hasNextPage'] ?? false;
        _isLoadingMore = false;
      });
    } catch (e) {
      log('Error loading more users: $e');
      _currentPage--;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _sendConnectRequest(String userId, int userIndex) async {
    try {
      HapticFeedback.lightImpact();

      final response = await _apiClient.post(
        '/api/user/add-friend',
        {'toFriendUser': userId},
      );

      setState(() {
        _filteredPeople[userIndex]['friendStatus'] = 'canCancel';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Connection request sent!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      log('Error sending connect request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send connection request'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleFriendAction(
      String userId, String action, int userIndex) async {
    try {
      HapticFeedback.mediumImpact();

      String endpoint;
      Map<String, dynamic> data;

      switch (action) {
        case 'accept':
          endpoint = '/api/user/accept-friend-request';
          data = {'toAcceptFriendUser': userId};
          break;
        case 'reject':
          endpoint = '/api/user/reject-friend-request';
          data = {'toRejectUser': userId};
          break;
        case 'unfriend':
          endpoint = '/api/user/unfriend-request';
          data = {'toUn_FriendUser': userId};
          break;
        case 'cancel':
          endpoint = '/api/user/cancel-friend-request';
          data = {'toFriendUser': userId};
          break;
        default:
          return;
      }

      final response = await _apiClient.post(endpoint, data);

      setState(() {
        if (action == 'accept') {
          _filteredPeople[userIndex]['friendStatus'] = 'friends';
        } else {
          _filteredPeople[userIndex]['friendStatus'] = 'connect';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Action completed!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      log('Error handling friend action: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete action'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToProfile(String userId) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: userId),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final fgColor = isDark ? Colors.white : Colors.black;
    final overlayColor =
        isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: overlayColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: dividerColor, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Icon(Icons.search, color: subTextColor, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Search alumni...',
                                hintStyle: TextStyle(
                                    color: subTextColor, fontFamily: 'Inter'),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  if (_searchQuery == val) {
                                    _loadUsers(refresh: true);
                                  }
                                });
                              },
                            ),
                          ),
                          // Filter button
                          _FilterButton(
                            value: _selectedRole,
                            options: roles,
                            onChanged: (val) {
                              setState(() => _selectedRole = val);
                              _loadUsers(refresh: true);
                            },
                            fgColor: fgColor,
                            bgColor: bgColor,
                            borderColor: dividerColor,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Alumni badge at the top center
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dividerColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _selectedRole,
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'Inter',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // List of cards
            Expanded(
              child: _buildContent(
                  bgColor, fgColor, subTextColor, dividerColor, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color bgColor, Color fgColor, Color subTextColor,
      Color dividerColor, bool isDark) {
    if (_isLoading && _filteredPeople.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty && _filteredPeople.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: subTextColor),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: fgColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadUsers(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: fgColor,
                foregroundColor: bgColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredPeople.isEmpty) {
      return Center(
        child: Text(
          'No $_selectedRole found.',
          style:
              TextStyle(color: subTextColor, fontSize: 16, fontFamily: 'Inter'),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredPeople.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredPeople.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = _filteredPeople[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _AlumniCard(
            user: user,
            userIndex: index,
            isDark: isDark,
            bgColor: bgColor,
            fgColor: fgColor,
            subTextColor: subTextColor,
            dividerColor: dividerColor,
            onConnect: _sendConnectRequest,
            onFriendAction: _handleFriendAction,
            onTap: _navigateToProfile,
          ),
        );
      },
    );
  }
}

class _AlumniCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final int userIndex;
  final bool isDark;
  final Color bgColor;
  final Color fgColor;
  final Color subTextColor;
  final Color dividerColor;
  final Function(String, int) onConnect;
  final Function(String, String, int) onFriendAction;
  final Function(String) onTap;

  const _AlumniCard({
    required this.user,
    required this.userIndex,
    required this.isDark,
    required this.bgColor,
    required this.fgColor,
    required this.subTextColor,
    required this.dividerColor,
    required this.onConnect,
    required this.onFriendAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friendStatus = user['friendStatus'] ?? 'connect';
    final role = user['role'] ?? 'student';
    final graduationYear = user['graduationYear'];
    final department = user['university']?['departmentId']?['name'];
    final campus = user['university']?['campusId']?['name'];
    final university = user['university']?['universityId']?['name'];

    return GestureDetector(
      onTap: () => onTap(user['_id']),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: dividerColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.white10 : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image with grayscale filter (original design)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  colorFilter:
                      const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                  child: user['profile']?['picture'] != null
                      ? Image.network(
                          user['profile']['picture'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 160,
                            width: double.infinity,
                            color: subTextColor.withOpacity(0.3),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: subTextColor,
                            ),
                          ),
                        )
                      : Container(
                          height: 160,
                          width: double.infinity,
                          color: subTextColor.withOpacity(0.3),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: subTextColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              // University logo and name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: bgColor,
                    radius: 16,
                    child: Icon(
                      Icons.school,
                      size: 20,
                      color: fgColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      university ?? campus ?? 'University',
                      style: TextStyle(
                        color: fgColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Name and verified
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      user['name'] ?? 'Unknown User',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: fgColor,
                        letterSpacing: -1.2,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Role, field and graduation year
              Text(
                _buildUserSubtitle(role, department, graduationYear),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subTextColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Divider
              Container(
                height: 1.2,
                width: 50,
                color: dividerColor,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              // Bio/Description
              if (user['profile']?['bio'] != null &&
                  user['profile']['bio'].isNotEmpty) ...[
                Text(
                  user['profile']['bio'],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                Text(
                  _getDefaultDescription(role),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 22),
              _buildActionButton(friendStatus, role),
            ],
          ),
        ),
      ),
    );
  }

  String _buildUserSubtitle(
      String role, String? department, int? graduationYear) {
    final roleDisplay = role[0].toUpperCase() + role.substring(1);

    if (role == 'alumni' && graduationYear != null) {
      if (department != null) {
        return '$department • Class of $graduationYear';
      }
      return 'Class of $graduationYear';
    } else if (department != null) {
      return '$roleDisplay • $department';
    }
    return roleDisplay;
  }

  String _getDefaultDescription(String role) {
    switch (role) {
      case 'alumni':
        return 'Experienced professional & proud alumnus.';
      case 'teacher':
        return 'Dedicated educator & researcher.';
      case 'student':
        return 'Passionate learner & future innovator.';
      default:
        return 'Member of our campus community.';
    }
  }

  Widget _buildActionButton(String friendStatus, String role) {
    switch (friendStatus) {
      case 'friends':
        return _ShadcnButton(
          text: 'Connected',
          onTap: () => onFriendAction(user['_id'], 'unfriend', userIndex),
          fgColor: bgColor,
          bgColor: Colors.green,
        );
      case 'canCancel':
        return _ShadcnButton(
          text: 'Request Sent',
          onTap: () => onFriendAction(user['_id'], 'cancel', userIndex),
          fgColor: bgColor,
          bgColor: Colors.orange,
        );
      case 'accept/reject':
        return Column(
          children: [
            _ShadcnButton(
              text: 'Accept Request',
              onTap: () => onFriendAction(user['_id'], 'accept', userIndex),
              fgColor: bgColor,
              bgColor: Colors.green,
            ),
            const SizedBox(height: 8),
            _ShadcnButton(
              text: 'Decline',
              onTap: () => onFriendAction(user['_id'], 'reject', userIndex),
              fgColor: Colors.red,
              bgColor: bgColor,
            ),
          ],
        );
      default:
        String roleTitle = role[0].toUpperCase() + role.substring(1);
        return _ShadcnButton(
          text: 'Connect with $roleTitle',
          onTap: () => onConnect(user['_id'], userIndex),
          fgColor: bgColor,
          bgColor: fgColor,
        );
    }
  }
}

class _ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color fgColor;
  final Color bgColor;

  const _ShadcnButton({
    required this.text,
    required this.onTap,
    required this.fgColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: fgColor, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Inter',
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final Color fgColor;
  final Color bgColor;
  final Color borderColor;

  const _FilterButton({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.fgColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => options
          .map((role) => PopupMenuItem<String>(
                value: role,
                child: Text(role,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontWeight: FontWeight.w500)),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: fgColor, size: 18),
          ],
        ),
      ),
    );
  }
}
