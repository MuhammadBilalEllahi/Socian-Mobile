import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';

class SocietyPage extends ConsumerStatefulWidget {
  final String societyId;
  const SocietyPage({super.key, required this.societyId});

  @override
  ConsumerState<SocietyPage> createState() => _SocietyPageState();
}

class _SocietyPageState extends ConsumerState<SocietyPage> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? societyData;
  List<dynamic> posts = [];
  List<dynamic> roles = [];
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;
  bool isMember = false;
  Map<String, dynamic>? authUser;
  bool editable = false;

  // shadcn black/white palette
  static const Color darkBg = Color(0xFF000000);
  static const Color darkFg = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFF888888);
  static const Color darkBorder = Color(0xFF222222);
  static const Color darkAccent = Color(0x00ffffff);

  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightFg = Color(0xFF000000);
  static const Color lightMuted = Color(0xFF888888);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightAccent = Color(0xFF000000);

  Map<String, Color> _getThemeColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      'bg': isDark ? darkBg : lightBg,
      'fg': isDark ? darkFg : lightFg,
      'muted': isDark ? darkMuted : lightMuted,
      'border': isDark ? darkBorder : lightBorder,
      'accent': isDark ? darkAccent : lightAccent,
    };
  }

  @override
  void initState() {
    super.initState();
    authUser = ref.read(authProvider).user;
    fetchSocietyDetails(page: 1, append: false);
    checkMembershipStatus();
  }

  Future<void> fetchSocietyDetails({int page = 1, bool append = false}) async {
    if (widget.societyId.isEmpty) return;
    setState(() {
      if (page == 1) {
        isLoading = true;
        error = null;
      } else {
        isLoadingMore = true;
      }
    });
    try {
      final response = await _apiClient.get(
        '/api/society/${widget.societyId}?page=$page&limit=$pageSize}',
      );
      log("response $response");
      if (response['isJoined'] == true) {
        setState(() {
          isMember = true;
        });
      }
      final society = response['society'] as Map<String, dynamic>?;
      final fetchedPosts = (response['posts'] ?? []) as List<dynamic>;

      final fetchedRoles = (society?['roles'] ?? []) as List<dynamic>;
      if (mounted) {
        setState(() {
          societyData = society;
          roles = fetchedRoles;
          if (append) {
            posts.addAll(fetchedPosts);
          } else {
            posts = fetchedPosts;
          }
          currentPage = page;
          hasMore = fetchedPosts.length == pageSize;
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "Failed to load society details";
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> checkMembershipStatus() async {
    try {
      final response = await _apiClient.get('/api/user/subscribedSocieties');
      final subscribedSocieties = response as List<dynamic>;
      final isSubscribed = subscribedSocieties
          .any((society) => society['_id'] == widget.societyId);
      if (mounted) {
        setState(() {
          isMember = isSubscribed;
        });
      }
    } catch (e) {
      debugPrint('Error checking membership status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check membership status')),
        );
      }
    }
  }

  Future<void> toggleMembership() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (isMember) {
        await _apiClient.get('/api/society/leave/${widget.societyId}');
        if (mounted) {
          setState(() {
            isMember = false;
            societyData?['totalMembers'] =
                (societyData?['totalMembers'] ?? 1) - 1;
          });
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Left society successfully')),
          );
        }
      } else {
        await _apiClient.get('/api/society/join/${widget.societyId}');
        if (mounted) {
          setState(() {
            isMember = true;
            societyData?['totalMembers'] =
                (societyData?['totalMembers'] ?? 0) + 1;
          });
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Joined society successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _loadMorePosts() {
    if (!isLoadingMore && hasMore) {
      fetchSocietyDetails(page: currentPage + 1, append: true);
    }
  }

  bool get isModerator {
    if (societyData == null || authUser == null) return false;
    final moderators = societyData?['moderators'] as List<dynamic>? ?? [];
    final userId = authUser?['_id']?.toString();
    return moderators.any((mod) => mod?['_id']?.toString() == userId);
  }

  Future<void> _showEditNameDescriptionDialog() async {
    final colors = _getThemeColors(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditNameDescriptionDialog(
        colors: colors,
        societyId: widget.societyId,
        initialName: societyData?['name'] ?? '',
        initialDescription: societyData?['description'] ?? '',
        apiClient: _apiClient,
        onSave: () => fetchSocietyDetails(page: 1, append: false),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Society updated')),
      );
    }
  }

  Future<void> _showEditImageDialog({required String type}) async {
    final colors = _getThemeColors(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditImageDialog(
        colors: colors,
        societyId: widget.societyId,
        type: type,
        initialUrl: societyData?[type] ?? '',
        apiClient: _apiClient,
        onSave: () => fetchSocietyDetails(page: 1, append: false),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${type == 'icon' ? 'Icon' : 'Banner'} updated')),
      );
    }
  }

  Future<void> _showAddRoleDialog() async {
    final colors = _getThemeColors(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AddRoleDialog(
        colors: colors,
        societyId: widget.societyId,
        apiClient: _apiClient,
        onSave: () => fetchSocietyDetails(page: 1, append: false),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role added')),
      );
    }
  }

  Future<void> _showAddModeratorDialog() async {
    final colors = _getThemeColors(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddModeratorDialog(
        colors: colors,
        societyId: widget.societyId,
        apiClient: _apiClient,
        onSave: () => fetchSocietyDetails(page: 1, append: false),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moderator added successfully')),
      );
    }
  }

  Future<bool> _showDeleteRoleConfirmationDialog(String roleTitle) async {
    final colors = _getThemeColors(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colors['bg'],
            surfaceTintColor: colors['bg'],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors['border']!, width: 1.5),
            ),
            title: Text(
              'Delete Role',
              style: TextStyle(
                color: colors['fg'],
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete the role "$roleTitle"? This action cannot be undone.',
              style: TextStyle(
                color: colors['fg'],
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colors['muted'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteRole(String roleId, String roleTitle) async {
    final confirmed = await _showDeleteRoleConfirmationDialog(roleTitle);
    if (!confirmed || !mounted) return;

    try {
      await _apiClient.post('/api/society/delete-role/${widget.societyId}', {
        'roleId': roleId,
      });
      await fetchSocietyDetails(page: 1, append: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildPostListItem(Map<String, dynamic> post) {
    final colors = _getThemeColors(context);
    final author = post['author'];
    final upvotes = post['upvotes'] ?? 0;
    final downvotes = post['downvotes'] ?? 0;
    final commentsCount = post['commentsCount'] ?? 0;
    final title = post['title'] ?? 'Untitled';
    final content = post['content'] ?? '';
    final createdAt = post['createdAt'];
    final timeAgo = createdAt != null
        ? _timeAgo(DateTime.tryParse(createdAt) ?? DateTime.now())
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: colors['bg'],
        border: Border(
          bottom: BorderSide(color: colors['border']!, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (author != null && author?['profile']?['picture'] != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        NetworkImage(author?['profile']?['picture']),
                    backgroundColor: colors['border'],
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors['border'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person, size: 18, color: colors['muted']),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    author?['name'] ?? 'Anonymous',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: colors['fg'],
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: colors['muted'],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: colors['fg'],
                letterSpacing: 0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (content.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  color: colors['muted'],
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                _MinimalIconButton(
                  icon: Icons.arrow_upward_rounded,
                  color: colors['accent']!,
                  onTap: () {},
                ),
                const SizedBox(width: 2),
                Text(
                  '${upvotes - downvotes}',
                  style: TextStyle(
                    color: colors['fg'],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                _MinimalIconButton(
                  icon: Icons.mode_comment_outlined,
                  color: colors['muted']!,
                  onTap: () {},
                ),
                const SizedBox(width: 2),
                Text(
                  '$commentsCount',
                  style: TextStyle(
                    color: colors['muted'],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 16),
                _MinimalIconButton(
                  icon: Icons.share_outlined,
                  color: colors['muted']!,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.year}/${date.month}/${date.day}';
  }

  Widget _buildSocietyInfo() {
    final colors = _getThemeColors(context);
    final bannerUrl = (societyData?['banner'] ?? '').toString();
    final iconUrl = (societyData?['icon'] ?? '').toString();
    final name = societyData?['name'] ?? '';
    final description = (societyData?['description'] ?? '').toString().trim();
    final members =
        societyData?['totalMembers'] ?? societyData?['membersCount'] ?? 0;
    final moderators = (societyData?['moderators'] is List)
        ? (societyData?['moderators'] as List)
        : [];

    final showEdit = editable && isModerator;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap:
                  showEdit ? () => _showEditImageDialog(type: 'banner') : null,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors['border'],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  image: bannerUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(bannerUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            colors['bg']!.withOpacity(0.10),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    if (bannerUrl.isEmpty)
                      Center(
                        child:
                            Icon(Icons.image, color: colors['muted'], size: 60),
                      ),
                    if (showEdit)
                      Positioned(
                        right: 16,
                        top: 16,
                        child: _MinimalIconButton(
                          icon: Icons.edit,
                          color: colors['accent']!,
                          onTap: () => _showEditImageDialog(type: 'banner'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: 32,
              child: GestureDetector(
                onTap:
                    showEdit ? () => _showEditImageDialog(type: 'icon') : null,
                child: Stack(
                  children: [
                    iconUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 44,
                            backgroundColor: colors['border'],
                            backgroundImage: NetworkImage(iconUrl),
                          )
                        : CircleAvatar(
                            radius: 44,
                            backgroundColor: colors['border'],
                            child: Icon(Icons.groups,
                                color: colors['muted'], size: 44),
                          ),
                    if (showEdit)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: _MinimalIconButton(
                          icon: Icons.edit,
                          color: colors['accent']!,
                          onTap: () => _showEditImageDialog(type: 'icon'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 56),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: colors['fg'],
                        letterSpacing: 0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showEdit)
                    _MinimalIconButton(
                      icon: Icons.edit,
                      color: colors['accent']!,
                      onTap: _showEditNameDescriptionDialog,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (description.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '❝$description❞',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors['muted'],
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (showEdit)
                      _MinimalIconButton(
                        icon: Icons.edit,
                        color: colors['accent']!,
                        onTap: _showEditNameDescriptionDialog,
                      ),
                  ],
                ),
              if (description.isNotEmpty) const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 20, color: colors['muted']),
                  const SizedBox(width: 8),
                  Text(
                    '$members members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors['muted'],
                      letterSpacing: 0,
                    ),
                  ),
                  if (!isModerator) ...[
                    const Spacer(),
                    _MinimalButton(
                      icon: isMember ? Icons.remove : Icons.add_circle,
                      label: isMember ? 'Leave' : 'Join',
                      colors: colors,
                      onTap: toggleMembership,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Moderators',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors['fg'],
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (showEdit)
                    _MinimalIconButton(
                      icon: Icons.add,
                      color: colors['accent']!,
                      onTap: _showAddModeratorDialog,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              moderators.isNotEmpty
                  ? SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: moderators.length,
                        itemBuilder: (context, index) {
                          final moderator = moderators[index];
                          final modName = moderator?['name'] ?? 'Unknown';
                          final modUsername =
                              moderator?['username'] ?? 'unknown';
                          final modImage = moderator?['profile']?['picture'];
                          final modId = moderator?['_id']?.toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: modId != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProfilePage(userId: modId),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  color: colors['bg'],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors['border']!,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors['muted']!.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: modImage != null
                                          ? NetworkImage(modImage)
                                          : null,
                                      backgroundColor: colors['border'],
                                      child: modImage == null
                                          ? Icon(
                                              Icons.person,
                                              size: 24,
                                              color: colors['muted'],
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      modName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors['fg'],
                                        letterSpacing: 0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '@$modUsername',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: colors['muted'],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No moderators listed.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: colors['muted'],
                          letterSpacing: 0,
                        ),
                      ),
                    ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Roles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors['fg'],
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (showEdit)
                    _MinimalIconButton(
                      icon: Icons.add,
                      color: colors['accent']!,
                      onTap: _showAddRoleDialog,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              roles.isNotEmpty || showEdit
                  ? SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: roles.length + (showEdit ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          if (showEdit && index == roles.length) {
                            return GestureDetector(
                              onTap: _showAddRoleDialog,
                              child: Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  color: colors['bg'],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colors['border']!,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 40,
                                    color: colors['accent'],
                                  ),
                                ),
                              ),
                            );
                          }

                          final role = roles[index];
                          final roleTitle = role['role'] ?? 'Unknown';
                          final roleName = role['name'] ?? 'Unknown';
                          final roleImage = role['picture'];
                          final roleId = role['_id']?.toString();

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                width: 164,
                                decoration: BoxDecoration(
                                  color: colors['bg'],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colors['border']!,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color:
                                          colors['accent']!.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: roleImage != null
                                              ? Image.network(
                                                  roleImage,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Container(
                                                      color: colors['border']!
                                                          .withOpacity(0.1),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color:
                                                              colors['accent'],
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      _buildImageFallback(
                                                          colors),
                                                )
                                              : _buildImageFallback(colors),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black
                                                      .withOpacity(0.02),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          14, 12, 14, 14),
                                      decoration: BoxDecoration(
                                        color: colors['bg']!.withOpacity(0.98),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            roleTitle.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: colors['accent'],
                                              letterSpacing: 0.8,
                                              height: 1.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            roleName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: colors['fg'],
                                              letterSpacing: 0.1,
                                              height: 1.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 2,
                                            width: 24,
                                            decoration: BoxDecoration(
                                              color: colors['accent']!
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (showEdit && roleId != null)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: GestureDetector(
                                    onTap: () => _deleteRole(roleId, roleTitle),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.redAccent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.redAccent
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No roles assigned.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: colors['muted'],
                          letterSpacing: 0,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors(context);
    if (isLoading) {
      return Scaffold(
        backgroundColor: colors['bg'],
        body: Center(
          child: CircularProgressIndicator(
            color: colors['accent'],
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (error != null) {
      return Scaffold(
        backgroundColor: colors['bg'],
        body: Center(
          child: Text(
            error!,
            style: TextStyle(
              color: colors['fg'],
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }
    if (societyData == null) {
      return Scaffold(
        backgroundColor: colors['bg'],
        body: Center(
          child: Text(
            'No society data found.',
            style: TextStyle(
              color: colors['fg'],
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors['bg'],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors['fg']),
        titleSpacing: 0,
        actions: [
          if (isModerator)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors['fg']),
              color: colors['bg'],
              surfaceTintColor: colors['bg'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: colors['border']!, width: 1),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  setState(() {
                    editable = !editable;
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        editable ? Icons.edit_off : Icons.edit,
                        color: colors['accent'],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        editable ? 'Disable Edit' : 'Enable Edit',
                        style: TextStyle(
                          color: colors['fg'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            _MinimalIconButton(
              icon: Icons.more_vert,
              color: colors['fg']!,
              onTap: () {},
            ),
        ],
      ),
      body: RefreshIndicator(
        color: colors['accent'],
        backgroundColor: colors['bg'],
        onRefresh: () => fetchSocietyDetails(page: 1, append: false),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildSocietyInfo(),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                padding: const EdgeInsets.only(bottom: 10.0, left: 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors['border']!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors['fg'],
                        letterSpacing: 0,
                      ),
                    ),
                    // const Spacer(),
                    // _MinimalButton(
                    //   icon: Icons.add,
                    //   label: 'Create Post',
                    //   colors: colors,
                    //   onTap: () {},
                    // ),
                  ],
                ),
              ),
            ),
            posts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24, top: 16),
                      child: Center(
                        child: Text(
                          'No posts yet. Be the first one to post!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colors['muted'],
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < posts.length) {
                          return _buildPostListItem(posts[index]);
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colors['accent'],
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                      },
                      childCount: posts.length + (hasMore ? 1 : 0),
                    ),
                  ),
            if (posts.isNotEmpty && hasMore)
              SliverToBoxAdapter(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!isLoadingMore &&
                        hasMore &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 100) {
                      _loadMorePosts();
                    }
                    return true;
                  },
                  child: const SizedBox(height: 1),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _EditNameDescriptionDialog extends StatefulWidget {
  final Map<String, Color> colors;
  final String societyId;
  final String initialName;
  final String initialDescription;
  final ApiClient apiClient;
  final VoidCallback onSave;

  const _EditNameDescriptionDialog({
    required this.colors,
    required this.societyId,
    required this.initialName,
    required this.initialDescription,
    required this.apiClient,
    required this.onSave,
  });

  @override
  _EditNameDescriptionDialogState createState() =>
      _EditNameDescriptionDialogState();
}

class _EditNameDescriptionDialogState
    extends State<_EditNameDescriptionDialog> {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName;
    descController.text = widget.initialDescription;
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
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
        'Edit Society',
        style: TextStyle(
          color: widget.colors['fg'],
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: widget.colors['muted']),
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
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            style: TextStyle(color: widget.colors['fg']),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: widget.colors['muted']),
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            'Save',
            style: TextStyle(
              color: widget.colors['accent'],
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final newName = nameController.text.trim();
            final newDesc = descController.text.trim();
            if (newName.isNotEmpty) {
              try {
                await widget.apiClient.put('/api/society/${widget.societyId}', {
                  'name': newName,
                  'description': newDesc,
                });
                widget.onSave();
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            }
          },
        ),
      ],
    );
  }
}

class _EditImageDialog extends StatefulWidget {
  final Map<String, Color> colors;
  final String societyId;
  final String type;
  final String initialUrl;
  final ApiClient apiClient;
  final VoidCallback onSave;

  const _EditImageDialog({
    required this.colors,
    required this.societyId,
    required this.type,
    required this.initialUrl,
    required this.apiClient,
    required this.onSave,
  });

  @override
  _EditImageDialogState createState() => _EditImageDialogState();
}

class _EditImageDialogState extends State<_EditImageDialog> {
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    urlController.text = widget.initialUrl;
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
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
        'Edit ${widget.type == 'icon' ? 'Icon' : 'Banner'}',
        style: TextStyle(
          color: widget.colors['fg'],
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: urlController,
        style: TextStyle(color: widget.colors['fg']),
        decoration: InputDecoration(
          labelText: '${widget.type == 'icon' ? 'Icon' : 'Banner'} URL',
          labelStyle: TextStyle(color: widget.colors['muted']),
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            'Save',
            style: TextStyle(
              color: widget.colors['accent'],
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final newUrl = urlController.text.trim();
            if (newUrl.isNotEmpty) {
              try {
                await widget.apiClient.put('/api/society/${widget.societyId}', {
                  widget.type: newUrl,
                });
                widget.onSave();
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            }
          },
        ),
      ],
    );
  }
}

class _AddRoleDialog extends StatefulWidget {
  final Map<String, Color> colors;
  final String societyId;
  final ApiClient apiClient;
  final VoidCallback onSave;

  const _AddRoleDialog({
    required this.colors,
    required this.societyId,
    required this.apiClient,
    required this.onSave,
  });

  @override
  _AddRoleDialogState createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<_AddRoleDialog> {
  final roleController = TextEditingController();
  final nameController = TextEditingController();
  final pictureController = TextEditingController();

  @override
  void dispose() {
    roleController.dispose();
    nameController.dispose();
    pictureController.dispose();
    super.dispose();
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
        'Add Role',
        style: TextStyle(
          color: widget.colors['fg'],
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: roleController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Role Title (e.g., President)',
              labelStyle: TextStyle(color: widget.colors['muted']),
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
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: widget.colors['muted']),
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
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pictureController,
            style: TextStyle(color: widget.colors['fg']),
            decoration: InputDecoration(
              labelText: 'Picture URL (optional)',
              labelStyle: TextStyle(color: widget.colors['muted']),
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            'Save',
            style: TextStyle(
              color: widget.colors['accent'],
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            final roleTitle = roleController.text.trim();
            final name = nameController.text.trim();
            final picture = pictureController.text.trim();
            if (roleTitle.isNotEmpty && name.isNotEmpty) {
              try {
                await widget.apiClient.post(
                  '/api/society/add-role/${widget.societyId}',
                  {
                    'role': roleTitle,
                    'name': name,
                    'picture': picture.isNotEmpty ? picture : null,
                  },
                );
                widget.onSave();
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            }
          },
        ),
      ],
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
      if (e is dio.DioException) {
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
                                            if (e is dio.DioException) {
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

class _MinimalIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MinimalIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _MinimalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Map<String, Color> colors;
  final VoidCallback onTap;

  const _MinimalButton({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors['bg'],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors['border']!,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: colors['bg'],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colors['accent']),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colors['accent'],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildImageFallback(Map<String, Color> colors) {
  return Container(
    color: colors['border']!.withOpacity(0.1),
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors['bg'],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline,
          size: 28,
          color: colors['muted'],
        ),
      ),
    ),
  );
}

class RoleCard extends StatefulWidget {
  final String? roleImage;
  final String roleTitle;
  final String roleName;
  final String? roleId; // Made required to ensure deletion works
  final bool
      showEdit; // Controls visibility of delete icon (moderator in edit mode)
  final Function(String, String)?
      onDelete; // Updated to use non-nullable roleId
  final VoidCallback? onTap;
  final Map<String, Color> colors;

  const RoleCard({
    super.key,
    this.roleImage,
    required this.roleTitle,
    required this.roleName,
    required this.roleId,
    this.showEdit = false,
    this.onDelete,
    this.onTap,
    required this.colors,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
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
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 164,
                    decoration: BoxDecoration(
                      color: widget.colors['bg'],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isHovered
                            ? widget.colors['accent']!.withOpacity(0.3)
                            : widget.colors['border']!,
                        width: _isHovered ? 1.5 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(_isHovered ? 0.08 : 0.04),
                          blurRadius: _isHovered ? 16 : 10,
                          offset: Offset(0, _isHovered ? 6 : 4),
                        ),
                        BoxShadow(
                          color: widget.colors['accent']!.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 4 / 3,
                              child: widget.roleImage != null
                                  ? Image.network(
                                      widget.roleImage!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: widget.colors['border']!
                                              .withOpacity(0.1),
                                          child: Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: widget.colors['accent'],
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildFallbackIcon(),
                                    )
                                  : _buildFallbackIcon(),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.02),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          decoration: BoxDecoration(
                            color: widget.colors['bg']!.withOpacity(0.98),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.roleTitle.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: widget.colors['accent'],
                                  letterSpacing: 0.8,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.roleName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: widget.colors['fg'],
                                  letterSpacing: 0.1,
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 2,
                                width: 24,
                                decoration: BoxDecoration(
                                  color:
                                      widget.colors['accent']!.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showEdit && widget.roleId!.isNotEmpty)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _EnhancedDeleteButton(
                        onTap: () => widget.onDelete
                            ?.call(widget.roleId ?? '', widget.roleTitle),
                        colors: widget.colors,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: widget.colors['border']!.withOpacity(0.1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.colors['bg'],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline,
            size: 28,
            color: widget.colors['muted'],
          ),
        ),
      ),
    );
  }
}

class _EnhancedDeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  final Map<String, Color> colors;

  const _EnhancedDeleteButton({
    required this.onTap,
    required this.colors,
  });

  @override
  State<_EnhancedDeleteButton> createState() => _EnhancedDeleteButtonState();
}

class _EnhancedDeleteButtonState extends State<_EnhancedDeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  // color: _isHovered: Colors.redAccent.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: _isHovered ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
