import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';

class ModeratorsPage extends StatelessWidget {
  final Map<String, Color> colors;
  final List<dynamic> moderators;
  final bool showEdit;
  final String societyId;
  final VoidCallback onAddModerator;

  const ModeratorsPage({
    super.key,
    required this.colors,
    required this.moderators,
    required this.showEdit,
    required this.societyId,
    required this.onAddModerator,
  });

  Future<void> _showAddModeratorDialog(BuildContext context) async {
    final apiClient = ApiClient();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddModeratorDialog(
        colors: colors,
        societyId: societyId,
        apiClient: apiClient,
        onSave: onAddModerator,
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moderator added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors['bg'],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors['fg']),
        title: Text(
          'Moderators',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors['fg'],
            letterSpacing: -0.3,
          ),
        ),
        titleSpacing: 0,
        actions: [
          if (showEdit)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _showAddModeratorDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors['border']!.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors['border']!, width: 1.2),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colors['accent'],
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: moderators.isNotEmpty
          ? ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: moderators.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final moderator = moderators[index];
                final modName = moderator?['name'] ?? 'Unknown';
                final modUsername = moderator?['username'] ?? 'unknown';
                final modImage = moderator?['profile']?['picture'];
                final modId = moderator?['_id']?.toString();
                return _ModeratorListTile(
                  colors: colors,
                  modName: modName,
                  modUsername: modUsername,
                  modImage: modImage,
                  modId: modId,
                  onTap: modId != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(userId: modId),
                            ),
                          );
                        }
                      : null,
                );
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No moderators listed.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colors['muted'],
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ModeratorListTile extends StatefulWidget {
  final Map<String, Color> colors;
  final String modName;
  final String modUsername;
  final String? modImage;
  final String? modId;
  final VoidCallback? onTap;

  const _ModeratorListTile({
    required this.colors,
    required this.modName,
    required this.modUsername,
    this.modImage,
    this.modId,
    this.onTap,
  });

  @override
  _ModeratorListTileState createState() => _ModeratorListTileState();
}

class _ModeratorListTileState extends State<_ModeratorListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.colors['bg'],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered
                        ? widget.colors['accent']!.withOpacity(0.3)
                        : widget.colors['border']!,
                    width: _isHovered ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.colors['border']!.withOpacity(0.5),
                    backgroundImage: widget.modImage != null
                        ? NetworkImage(widget.modImage!)
                        : null,
                    child: widget.modImage == null
                        ? Icon(
                            Icons.person,
                            size: 24,
                            color: widget.colors['muted'],
                          )
                        : null,
                  ),
                  title: Text(
                    widget.modName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.colors['fg'],
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '@${widget.modUsername}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: widget.colors['muted'],
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: widget.colors['muted'],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddModeratorDialog extends StatefulWidget {
  final Map<String, Color> colors;
  final String societyId;
  final ApiClient apiClient;
  final VoidCallback onSave;

  const _AddModeratorDialog({
    required this.colors,
    required this.societyId,
    required this.apiClient,
    required this.onSave,
  });

  @override
  _AddModeratorDialogState createState() => _AddModeratorDialogState();
}

class _AddModeratorDialogState extends State<_AddModeratorDialog> {
  final searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoadingSearch = false;
  String? searchError;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _searchCampusUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await widget.apiClient.get(
        '/api/user/search-campus-users',
        queryParameters: {'query': query},
      );
      return response['users'] ?? [];
    } catch (e) {
      String errorMsg = 'Failed to search users';
      if (e is DioException) {
        errorMsg +=
            ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
        debugPrint('Dio error searching campus users: $errorMsg');
      } else {
        debugPrint('Unexpected error searching campus users: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.colors['bg'],
      surfaceTintColor: widget.colors['bg'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.colors['border']!, width: 1.5),
      ),
      title: Text(
        'Add Moderator',
        style: TextStyle(
          color: widget.colors['fg'],
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Search campus users',
              labelStyle: TextStyle(color: widget.colors['muted']),
              prefixIcon: Icon(Icons.search, color: widget.colors['muted']),
              filled: true,
              fillColor: widget.colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['accent']!),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) async {
              if (!mounted) return;
              setState(() {
                isLoadingSearch = true;
                searchError = null;
              });
              try {
                final results = await _searchCampusUsers(value.trim());
                if (mounted) {
                  setState(() {
                    searchResults = results;
                    isLoadingSearch = false;
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    isLoadingSearch = false;
                    searchError = 'Search failed. Please try again.';
                  });
                }
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            height: 200,
            child: isLoadingSearch
                ? Center(
                    child: CircularProgressIndicator(
                      color: widget.colors['accent'],
                      strokeWidth: 2,
                    ),
                  )
                : searchError != null
                    ? Center(
                        child: Text(
                          searchError!,
                          style: TextStyle(color: widget.colors['muted']),
                        ),
                      )
                    : searchResults.isEmpty
                        ? Center(
                            child: Text(
                              searchController.text.isEmpty
                                  ? 'Enter a name or username'
                                  : 'No users found',
                              style: TextStyle(color: widget.colors['muted']),
                            ),
                          )
                        : ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final user = searchResults[index];
                              final userName =
                                  user['name']?.toString() ?? 'Unknown';
                              final userId = user['_id']?.toString();
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      user?['profile']?['picture'] != null
                                          ? NetworkImage(
                                              user?['profile']?['picture'])
                                          : null,
                                  backgroundColor: widget.colors['border'],
                                  child: user?['profile']?['picture'] == null
                                      ? Icon(Icons.person,
                                          size: 16,
                                          color: widget.colors['muted'])
                                      : null,
                                ),
                                title: Text(
                                  userName,
                                  style: TextStyle(
                                    color: widget.colors['fg'],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  '@${user['username'] ?? 'unknown'}',
                                  style: TextStyle(
                                    color: widget.colors['muted'],
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: userId != null
                                    ? () async {
                                        try {
                                          await widget.apiClient.post(
                                            '/api/society/add-moderator/${widget.societyId}',
                                            {'userId': userId},
                                          );
                                          widget.onSave();
                                          if (mounted) {
                                            Navigator.of(context).pop(userId);
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            String errorMsg =
                                                'Failed to add moderator';
                                            if (e is DioException) {
                                              errorMsg +=
                                                  ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
                                              debugPrint(
                                                  'Dio error adding moderator: $errorMsg');
                                            } else {
                                              debugPrint(
                                                  'Unexpected error adding moderator: $e');
                                            }
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(content: Text(errorMsg)),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                              );
                            },
                          ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: widget.colors['muted'],
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
