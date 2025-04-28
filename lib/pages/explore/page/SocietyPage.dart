import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';

class SocietyPage extends StatefulWidget {
  final String societyId;
  const SocietyPage({super.key, required this.societyId});

  @override
  State<SocietyPage> createState() => _SocietyPageState();
}

class _SocietyPageState extends State<SocietyPage> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? societyData;
  List<dynamic> posts = [];
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;

  // shadcn/minimal palette
  static const Color bg = Color(0xFF18181B);
  static const Color fg = Color(0xFFF4F4F5);
  static const Color muted = Color(0xFF71717A);
  static const Color border = Color(0xFF27272A);
  static const Color accent = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    fetchSocietyDetails(page: 1, append: false);
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
        '/api/society/${widget.societyId}?page=$page&limit=$pageSize',
      );
      final society = response['society'] as Map<String, dynamic>?;
      final fetchedPosts = (response['posts'] ?? []) as List<dynamic>;
      setState(() {
        societyData = society;
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
    } catch (e) {
      setState(() {
        error = "Failed to load society details";
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _loadMorePosts() {
    if (!isLoadingMore && hasMore) {
      fetchSocietyDetails(page: currentPage + 1, append: true);
    }
  }

  Widget _buildPostListItem(Map<String, dynamic> post) {
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

    // shadcn: border, subtle, minimal, rounded, no shadow, muted
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author and time
            Row(
              children: [
                if (author != null && author['image'] != null)
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(author['image']),
                    backgroundColor: Colors.transparent,
                  )
                else
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.person, size: 16, color: muted),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    author?['name'] ?? 'Anonymous',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: fg,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: fg,
                letterSpacing: 0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (content.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: muted,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            // Actions row
            Row(
              children: [
                _MinimalIconButton(
                  icon: Icons.arrow_upward_rounded,
                  color: accent,
                  onTap: () {},
                ),
                const SizedBox(width: 2),
                Text(
                  '${upvotes - downvotes}',
                  style: const TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
                _MinimalIconButton(
                  icon: Icons.mode_comment_outlined,
                  color: muted,
                  onTap: () {},
                ),
                const SizedBox(width: 2),
                Text(
                  '$commentsCount',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 14),
                _MinimalIconButton(
                  icon: Icons.share_outlined,
                  color: muted,
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
    final bannerUrl = (societyData?['banner'] ?? '').toString();
    final iconUrl = (societyData?['icon'] ?? '').toString();
    final name = societyData?['name'] ?? '';
    final description = (societyData?['description'] ?? '').toString().trim();
    final members =
        societyData?['totalMembers'] ?? societyData?['membersCount'] ?? 0;
    final moderators = (societyData?['moderators'] is List)
        ? (societyData?['moderators'] as List)
        : [];

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: border,
                image: bannerUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(bannerUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: bannerUrl.isEmpty
                  ? Center(
                      child: Icon(Icons.image, color: muted, size: 60),
                    )
                  : null,
            ),
            Positioned(
              bottom: -40,
              left: 24,
              child: iconUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 40,
                      backgroundColor: border,
                      backgroundImage: NetworkImage(iconUrl),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: border,
                      child: Icon(Icons.groups, color: muted, size: 40),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 50), // To accommodate CircleAvatar space
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: fg,
                  letterSpacing: 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (description.isNotEmpty)
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: muted,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              if (description.isNotEmpty) const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.group, size: 20, color: muted),
                  const SizedBox(width: 8),
                  Text(
                    '$members members',
                    style: const TextStyle(
                      fontSize: 16,
                      color: muted,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Moderators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: fg,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              if (moderators.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: moderators.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final moderator = moderators[index];
                      final image = moderator?['profile']?['image'] ??
                          moderator?['image'] ??
                          '';
                      final modName = moderator?['name'] ?? '';
                      return Column(
                        children: [
                          image.toString().isNotEmpty
                              ? CircleAvatar(
                                  radius: 24,
                                  backgroundColor: border,
                                  backgroundImage: NetworkImage(image),
                                )
                              : CircleAvatar(
                                  radius: 24,
                                  backgroundColor: border,
                                  child: Icon(Icons.person,
                                      color: muted, size: 20),
                                ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              modName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: muted,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              if (moderators.isEmpty)
                const Text(
                  "No moderators listed.",
                  style: TextStyle(
                    fontSize: 13,
                    color: muted,
                    fontWeight: FontWeight.w400,
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
    if (isLoading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(
            color: accent,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (error != null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }
    if (societyData == null) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: Text(
            "No society data found.",
            style: TextStyle(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: fg),
        titleSpacing: 0,
        title: Text(
          societyData?['name'] ?? '',
          style: const TextStyle(
            color: fg,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            overflow: TextOverflow.ellipsis,
            letterSpacing: 0,
          ),
        ),
        actions: [
          _MinimalIconButton(
            icon: Icons.more_vert,
            color: fg,
            onTap: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: accent,
        backgroundColor: bg,
        onRefresh: () => fetchSocietyDetails(page: 1, append: false),
        child: CustomScrollView(
          slivers: [
            // Banner (minimal, no card, rounded)
            if (societyData?['banner'] != null &&
                (societyData?['banner'] as String).isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(societyData?['banner']),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.22),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
            // Society info (bordered, minimal)
            SliverToBoxAdapter(
              child: _buildSocietyInfo(),
            ),
            // Posts header (minimal, border bottom)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: fg,
                        letterSpacing: 0,
                      ),
                    ),
                    const Spacer(),
                    _MinimalButton(
                      icon: Icons.add,
                      label: 'Create Post',
                      onTap: () {
                        // TODO: Implement create post
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Posts list (bordered, minimal)
            posts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 36.0, horizontal: 22),
                      child: Center(
                        child: Text(
                          "No posts yet. Be the first one to post!",
                          style: const TextStyle(
                            color: muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
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
                          final post = posts[index];
                          return _buildPostListItem(post);
                        } else {
                          // Loading indicator for pagination
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: accent,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                      },
                      childCount: posts.length + (hasMore ? 1 : 0),
                    ),
                  ),
            // Infinite scroll trigger
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
                    return false;
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

// Minimal icon button for shadcn style
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
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

// Minimal button for shadcn style
class _MinimalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MinimalButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
                color: _SocietyPageState.accent.withOpacity(0.18), width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: _SocietyPageState.accent),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: _SocietyPageState.accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
