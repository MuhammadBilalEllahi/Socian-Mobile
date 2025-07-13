import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shimmer/shimmer.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/explore/page/ModeratorsPage.dart';
import 'package:socian/pages/explore/page/verification/SocietyVerification.dart';
import 'package:socian/pages/home/widgets/components/post/page/PostDetailPage.dart';
import 'package:socian/pages/home/widgets/components/post/post_stat_item.dart';
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
  File? bannerImage;
  File? iconImage;

  // shadcn black/white palette
  static const Color darkBg = Color(0xFF000000);
  static const Color darkFg = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFF888888);
  static const Color darkBorder = Color(0xFF222222);
  static const Color darkAccent = Color(0xFF1E90FF);

  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightFg = Color(0xFF000000);
  static const Color lightMuted = Color(0xFF888888);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightAccent = Color(0xFF1E90FF);

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
        '/api/society/${widget.societyId}?page=$page&limit=$pageSize',
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to check membership status')),
        // );
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


Future<void> _showReportDialog(String societyId) async {
  try {
    // Fetch available report types from the API
    final response = await _apiClient.get('/api/report/types');
    final List<dynamic> reportTypes = response['reportTypes'] ?? [];

    if (reportTypes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No report types available')),
        );
      }
      return;
    }

    // Show dialog with dynamic report types
    final selectedReportType = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getThemeColors(context)['bg'],
        surfaceTintColor: _getThemeColors(context)['bg'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _getThemeColors(context)['border']!, width: 1.5),
        ),
        title: Text(
          'Report Society',
          style: TextStyle(
            color: _getThemeColors(context)['fg'],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: reportTypes.map<Widget>((reportType) {
                return ListTile(
                  title: Text(
                    reportType['name'] ?? 'Unknown',
                    style: TextStyle(color: _getThemeColors(context)['fg']),
                  ),
                  onTap: () => Navigator.pop(context, {
                    'id': reportType['_id'],
                    'name': reportType['name'],
                  }),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: _getThemeColors(context)['muted'],
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    // Show confirmation dialog
    if (selectedReportType != null && mounted) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _getThemeColors(context)['bg'],
          surfaceTintColor: _getThemeColors(context)['bg'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _getThemeColors(context)['border']!, width: 1.5),
          ),
          title: Text(
            'Confirm Report',
            style: TextStyle(
              color: _getThemeColors(context)['fg'],
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to report this society for "${selectedReportType['name']}"?',
            style: TextStyle(color: _getThemeColors(context)['fg']),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: _getThemeColors(context)['muted']),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _getThemeColors(context)['accent'],
              ),
              child: Text(
                'Report',
                style: TextStyle(color: _getThemeColors(context)['onAccent']),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        try {
          // Send report to the backend
          final response = await _apiClient.post('/api/report/society', {
            'societyId': societyId,
            'reportType': selectedReportType['id'],
            'reason': selectedReportType['name'],
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ?? 'Society reported successfully'),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error reporting society: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to report society')),
            );
          }
        }
      }
    }
  } catch (e) {
    debugPrint('Error fetching report types: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load report types')),
      );
    }
  }
}



  //   Future<void> _showReportDialog(String societyId) async {
  //   try {
  //     // Fetch available report types from the API
  //     final response = await _apiClient.get('/api/report/types');
  //     final List<dynamic> reportTypes = response['reportTypes'] ?? [];

  //     if (reportTypes.isEmpty) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('No report types available')),
  //         );
  //       }
  //       return;
  //     }

  //     // Show dialog with dynamic report types
  //     final selectedReportType = await showDialog<Map<String, dynamic>>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         backgroundColor: _getThemeColors(context)['bg'],
  //         surfaceTintColor: _getThemeColors(context)['bg'],
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           side: BorderSide(color: _getThemeColors(context)['border']!, width: 1.5),
  //         ),
  //         title: Text(
  //           'Report Society',
  //           style: TextStyle(
  //             color: _getThemeColors(context)['fg'],
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         content: ConstrainedBox(
  //           constraints: BoxConstraints(
  //             maxHeight: MediaQuery.of(context).size.height * 0.5,
  //           ),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: reportTypes.map<Widget>((reportType) {
  //                 return ListTile(
  //                   title: Text(
  //                     reportType['name'] ?? 'Unknown',
  //                     style: TextStyle(color: _getThemeColors(context)['fg']),
  //                   ),
  //                   onTap: () => Navigator.pop(context, {
  //                     'id': reportType['_id'],
  //                     'name': reportType['name'],
  //                   }),
  //                 );
  //               }).toList(),
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: _getThemeColors(context)['muted'],
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //         ],
  //       ),
  //     );

  //     if (selectedReportType != null && mounted) {
  //       try {
  //         // Send report to the backend
  //         final response = await _apiClient.post('/api/report/society', {
  //           'societyId': societyId,
  //           'reportType': selectedReportType['id'],
  //           'reason': selectedReportType['name'],
  //         });

  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(response['message'] ?? 'Society reported successfully'),
  //             ),
  //           );
  //         }
  //       } catch (e) {
  //         debugPrint('Error reporting society: $e');
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Failed to report society')),
  //           );
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching report types: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to load report types')),
  //       );
  //     }
  //   }
  // }





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

  Future<void> _pickImage(bool banner, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() {
          if (banner) {
            bannerImage = file;
          } else {
            iconImage = file;
          }
        });
        await _uploadImage(banner);
      }
    }
  }

  Future<bool> _uploadImage(bool banner) async {
    final selectedImage = banner ? bannerImage : iconImage;
    if (selectedImage == null) return false;

    try {
      final apiClient = ApiClient();
      final formData = {
        'file': [
          await dio.MultipartFile.fromFile(
            selectedImage.path,
            filename: path.basename(selectedImage.path),
            contentType: MediaType(
                'image', path.extension(selectedImage.path).substring(1)),
          ),
        ],
        'societyId': widget.societyId,
      };

      final response = await apiClient.postFormData(
          '/api/society/${banner ? 'banner' : 'icon'}/upload', formData);

      if (response['url'] != null) {
        final url = response['url'];
        setState(() {
          societyData?[banner ? 'banner' : 'icon'] = url;
          if (banner) {
            bannerImage = null;
          } else {
            iconImage = null;
          }
        });
        log("Image uploaded successfully: $url");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${banner ? 'Banner' : 'Icon'} updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      log("Error uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
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















  Widget _buildPostListItem(BuildContext context, Map<String, dynamic> post) {
    final colors = _getThemeColors(context);
    final author = post['author'] ?? {};
    final timeAgo = post['createdAt'] != null
        ? _timeAgo(DateTime.tryParse(post['createdAt']) ?? DateTime.now())
        : '';
    final title = post['title'] ?? 'Untitled';
    final content = post['content'] ?? '';
    final commentsCount = post['commentsCount'] ?? 0;

    return Consumer(
      builder: (context, ref, child) {
        final authUser = ref.watch(authProvider).user;
        final currentUserId = authUser?['_id'];
        final voteId = post['voteId'] ?? {};
        bool isLiked = voteId['userVotes']?[currentUserId] == 'upvote';
        bool isDisliked = voteId['userVotes']?[currentUserId] == 'downvote';
        bool isVoting = false;

        Future<void> votePost(String voteType) async {
          if (isVoting) return;
          final apiClient = ApiClient();
          final previousUpVotes = voteId['upVotesCount'] ?? 0;
          final previousDownVotes = voteId['downVotesCount'] ?? 0;
          final previousIsLiked = isLiked;
          final previousIsDisliked = isDisliked;

          // Optimistic UI update
          if (voteType == 'upvote') {
            if (isLiked) {
              voteId['upVotesCount'] = (voteId['upVotesCount'] ?? 0) - 1;
              isLiked = false;
            } else {
              voteId['upVotesCount'] = (voteId['upVotesCount'] ?? 0) + 1;
              if (isDisliked) {
                voteId['downVotesCount'] = (voteId['downVotesCount'] ?? 0) - 1;
                isDisliked = false;
              }
              isLiked = true;
            }
          } else if (voteType == 'downvote') {
            if (isDisliked) {
              voteId['downVotesCount'] = (voteId['downVotesCount'] ?? 0) - 1;
              isDisliked = false;
            } else {
              voteId['downVotesCount'] = (voteId['downVotesCount'] ?? 0) + 1;
              if (isLiked) {
                voteId['upVotesCount'] = (voteId['upVotesCount'] ?? 0) - 1;
                isLiked = false;
              }
              isDisliked = true;
            }
          }

          try {
            final response = await apiClient.post('/api/posts/vote-post', {
              'postId': post['_id'],
              'voteType': voteType,
            });
            voteId['upVotesCount'] = response['upVotesCount'];
            voteId['downVotesCount'] = response['downVotesCount'];
            if (response['noneSelected'] == true) {
              isLiked = false;
              isDisliked = false;
            } else {
              isLiked =
                  voteType == 'upvote' && response['noneSelected'] != true;
              isDisliked =
                  voteType == 'downvote' && response['noneSelected'] != true;
            }
          } catch (e) {
            debugPrint('Error voting: $e');
            voteId['upVotesCount'] = previousUpVotes;
            voteId['downVotesCount'] = previousDownVotes;
            isLiked = previousIsLiked;
            isDisliked = previousIsDisliked;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to vote: $e')),
            );
          } finally {
            isVoting = false;
          }
        }

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
            child: GestureDetector(


           onTap: () {
            
              
            },        




              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (author['profile']?['picture'] != null)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(author['profile']['picture']),
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
                          child: Icon(Icons.person,
                              size: 18, color: colors['muted']),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          author['name'] ?? 'Anonymous',
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
                      const SizedBox(
                        width: 10,
                      )
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
                      PostStatItem(
                        icon: isLiked ? Icons.favorite : Icons.favorite_outline,
                        count: voteId['upVotesCount'] ?? 0,
                        onTap: () => votePost('upvote'),
                        isActive: isLiked,
                      ),
                      const SizedBox(width: 2),
                      PostStatItem(
                        icon: isDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        count: voteId['downVotesCount'] ?? 0,
                        onTap: () => votePost('downvote'),
                        isActive: isDisliked,
                      ),
                      const SizedBox(width: 16),
                      
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildShimmerIcon(Map<String, Color> colors) {
    return Shimmer.fromColors(
      baseColor: colors['border']!.withOpacity(0.3),
      highlightColor: colors['bg']!.withOpacity(0.1),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: colors['border'],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerLayout(Map<String, Color> colors) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildShimmerSocietyInfo(colors),
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
            child: _buildShimmerText(colors, width: 60, height: 16),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildShimmerPost(colors),
            childCount: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerSocietyInfo(Map<String, Color> colors) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildShimmerContainer(colors, width: double.infinity, height: 180),
            Positioned(
              bottom: -44,
              left: 32,
              child: _buildShimmerContainer(colors,
                  width: 88, height: 88, isCircle: true),
            ),
          ],
        ),
        const SizedBox(height: 56),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerText(colors, width: 200, height: 26),
              const SizedBox(height: 10),
              _buildShimmerText(colors, width: double.infinity, height: 16),
              const SizedBox(height: 6),
              _buildShimmerText(colors, width: 250, height: 16),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildShimmerContainer(colors,
                      width: 20, height: 20, isCircle: true),
                  const SizedBox(width: 8),
                  _buildShimmerText(colors, width: 100, height: 16),
                  const Spacer(),
                  _buildShimmerContainer(colors,
                      width: 80, height: 32, borderRadius: 8),
                ],
              ),
              const SizedBox(height: 28),
              _buildShimmerText(colors, width: 120, height: 18),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildShimmerContainer(colors,
                        width: 150, height: 120, borderRadius: 12),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildShimmerText(colors, width: 80, height: 18),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildShimmerContainer(colors,
                        width: 164, height: 220, borderRadius: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerPost(Map<String, Color> colors) {
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
                _buildShimmerContainer(colors,
                    width: 32, height: 32, isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildShimmerText(colors, width: 120, height: 15)),
                const SizedBox(width: 8),
                _buildShimmerText(colors, width: 60, height: 12),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmerText(colors, width: double.infinity, height: 17),
            const SizedBox(height: 6),
            _buildShimmerText(colors, width: 300, height: 15),
            const SizedBox(height: 6),
            _buildShimmerText(colors, width: 200, height: 15),
            const SizedBox(height: 18),
            Row(
              children: [
                _buildShimmerContainer(colors,
                    width: 24, height: 24, isCircle: true),
                const SizedBox(width: 8),
                _buildShimmerText(colors, width: 30, height: 14),
                const SizedBox(width: 16),
                _buildShimmerContainer(colors,
                    width: 24, height: 24, isCircle: true),
                const SizedBox(width: 8),
                _buildShimmerText(colors, width: 20, height: 14),
                const SizedBox(width: 16),
                _buildShimmerContainer(colors,
                    width: 24, height: 24, isCircle: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(
    Map<String, Color> colors, {
    required double width,
    required double height,
    bool isCircle = false,
    double? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: colors['border']!.withOpacity(0.3),
      highlightColor: colors['bg']!.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors['border'],
          borderRadius: isCircle
              ? BorderRadius.circular(width / 2)
              : BorderRadius.circular(borderRadius ?? 4),
        ),
      ),
    );
  }

  Widget _buildShimmerText(
    Map<String, Color> colors, {
    required double width,
    required double height,
  }) {
    return Shimmer.fromColors(
      baseColor: colors['border']!.withOpacity(0.3),
      highlightColor: colors['bg']!.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors['border'],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: showEdit ? () => _pickImage(true, context) : null,
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
                          onTap: () => _pickImage(true, context),
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
                onTap: showEdit ? () => _pickImage(false, context) : null,
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
                          onTap: () => _pickImage(false, context),
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
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colors['fg'],
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (societyData?['verified'] == true) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? colors['accent']!.withOpacity(0.1)
                            : colors['accent']!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: isDarkMode
                                ? colors['accent']!.withOpacity(0.2)
                                : colors['accent']!.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              color: isDarkMode
                                  ? colors['accent']!.withOpacity(0.8)
                                  : colors['accent']!.withOpacity(0.8),
                              size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: isDarkMode
                                  ? colors['accent']!.withOpacity(0.8)
                                  : colors['accent']!.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (showEdit) ...[
                    const SizedBox(width: 8),
                    _MinimalIconButton(
                      icon: Icons.edit,
                      color: colors['accent']!,
                      onTap: _showEditNameDescriptionDialog,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 15,
                                color: colors['muted'],
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (showEdit) ...[
                            const SizedBox(width: 8),
                            _MinimalIconButton(
                              icon: Icons.edit,
                              color: colors['accent']!,
                              onTap: _showEditNameDescriptionDialog,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              if (description.isNotEmpty) const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors['border']!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          Icon(Icons.group, size: 16, color: colors['muted']),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$members members',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors['muted'],
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (!isModerator) ...[
                      const Spacer(),
                      _MinimalButton(
                        icon: isMember ? Icons.check : Icons.add,
                        label: isMember ? 'Joined' : 'Join',
                        colors: colors,
                        onTap: toggleMembership,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24, top: 28),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModeratorsPage(
                          colors: colors,
                          moderators: moderators,
                          showEdit: showEdit,
                          societyId: widget.societyId,
                          onAddModerator: () =>
                              fetchSocietyDetails(page: 1, append: false),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors['border']!.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors['border']!, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Moderators',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors['fg'],
                            letterSpacing: -0.2,
                          ),
                        ),
                        Icon(Icons.arrow_forward,
                            color: colors['accent'], size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Roles',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors['fg'],
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (showEdit)
                      GestureDetector(
                        onTap: _showAddRoleDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors['border']!.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: colors['border']!, width: 1.2),
                          ),
                          child: Icon(
                            Icons.add,
                            color: colors['accent'],
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
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
                          final roleName = role['user']?['name'] ?? 'Unknown';
                          final roleImage =
                              role['user']?['profile']?['picture'];
                          final roleId = role['_id']?.toString() ?? '';

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
                                                        child: SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: colors[
                                                                'accent'],
                                                            strokeWidth: 2.5,
                                                          ),
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
                              if (showEdit && roleId.isNotEmpty)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: _EnhancedDeleteButton(
                                    onTap: () => _deleteRole(roleId, roleTitle),
                                    colors: colors,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
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
                    ),

              //hellooooooooooo
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors(context);
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
    if (isLoading || societyData == null) {
      return Scaffold(
        backgroundColor: colors['bg'],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: colors['fg']),
          titleSpacing: 0,
          actions: [
            _buildShimmerIcon(colors),
          ],
        ),
        body: _buildShimmerLayout(colors),
      );
    }

    return Scaffold(
      backgroundColor: colors['bg'],
      appBar: 
      
      
      
      
      // AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: colors['fg']),
      //   titleSpacing: 0,
      //   actions: [
      //     if (isModerator)
      //       PopupMenuButton<String>(
      //         icon: Icon(Icons.more_vert, color: colors['fg']),
      //         color: colors['bg'],
      //         surfaceTintColor: colors['bg'],
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //           side: BorderSide(color: colors['border']!, width: 1),
      //         ),
      //         onSelected: (value) {
      //           if (value == 'edit') {
      //             setState(() {
      //               editable = !editable;
      //             });
      //           }
      //           if (value == 'verify') {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => SocietyVerification(
      //                         societyId: societyData?['_id'],
      //                         societyName: societyData?['name'],
      //                       )),
      //             );
      //           }
      //         },
      //         itemBuilder: (BuildContext context) => [
      //           PopupMenuItem<String>(
      //             value: 'edit',
      //             child: Row(
      //               children: [
      //                 Icon(
      //                   editable ? Icons.edit_off : Icons.edit,
      //                   color: colors['accent'],
      //                   size: 18,
      //                 ),
      //                 const SizedBox(width: 8),
      //                 Text(
      //                   editable ? 'Disable Edit' : 'Enable Edit',
      //                   style: TextStyle(
      //                     color: colors['fg'],
      //                     fontWeight: FontWeight.w500,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           PopupMenuItem<String>(
      //             value: 'verify',
      //             child: Row(
      //               children: [
      //                 Icon(Icons.verified, color: colors['accent'], size: 18),
      //                 const SizedBox(width: 8),
      //                 Text(
      //                   'Verify Society',
      //                   style: TextStyle(
      //                     color: colors['fg'],
      //                     fontWeight: FontWeight.w500,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       )
      //     else
      //       _MinimalIconButton(
      //         icon: Icons.more_vert,
      //         color: colors['fg']!,
      //         onTap: () {},
      //       ),
      //   ],
      // ),

AppBar(
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
                if (value == 'verify') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SocietyVerification(
                              societyId: societyData?['_id'],
                              societyName: societyData?['name'],
                            )),
                  );
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
                PopupMenuItem<String>(
                  value: 'verify',
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: colors['accent'], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Verify Society',
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
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors['fg']),
              color: colors['bg'],
              surfaceTintColor: colors['bg'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: colors['border']!, width: 1),
              ),
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog(widget.societyId);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Report Society',
                        style: TextStyle(
                          color: colors['fg'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                margin: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colors['bg'],
                  border: Border(
                    bottom: BorderSide(color: colors['border']!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors['border']!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          Icon(Icons.article, size: 16, color: colors['muted']),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors['fg'],
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors['border']!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${posts.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors['muted'],
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
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
                          // return _buildPostListItem(context, posts[index]);
                          return _buildPostListItem(context, posts[index]);
                        } else {
                          return isLoadingMore
                              ? _buildShimmerPost(colors)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18.0),
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
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: widget.colors['border']!, width: 1),
      ),
      contentPadding: const EdgeInsets.all(24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Text(
        'Edit Society',
        style: TextStyle(
          color: widget.colors['fg'],
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(
              color: widget.colors['fg'],
              fontSize: 14,
              letterSpacing: -0.1,
            ),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(
                color: widget.colors['muted'],
                fontSize: 13,
              ),
              filled: true,
              fillColor: widget.colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: widget.colors['accent']!, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            style: TextStyle(
              color: widget.colors['fg'],
              fontSize: 14,
              letterSpacing: -0.1,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(
                color: widget.colors['muted'],
                fontSize: 13,
              ),
              filled: true,
              fillColor: widget.colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colors['border']!),
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: widget.colors['accent']!, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: widget.colors['muted'],
              fontWeight: FontWeight.w500,
              fontSize: 13,
              letterSpacing: -0.1,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.colors['accent'],
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
              foregroundColor: widget.colors['bg'],
            ),
            child: Text(
              'Save',
              style: TextStyle(
                color: widget.colors['bg'],
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: -0.1,
              ),
            ),
            onPressed: () async {
              final newName = nameController.text.trim();
              final newDesc = descController.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await widget.apiClient
                      .put('/api/society/${widget.societyId}', {
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
        ),
      ],
    );
  }
}

class _EditImageDialog extends StatelessWidget {
  final Map<String, Color> colors;
  final String societyId;
  final String type;
  final ApiClient apiClient;
  final VoidCallback onSave;

  const _EditImageDialog({
    required this.colors,
    required this.societyId,
    required this.type,
    required this.apiClient,
    required this.onSave,
  });

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${type == 'icon' ? 'Icon' : 'Banner'} Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        final file = File(image.path);
        try {
          final formData = {
            'file': [
              await dio.MultipartFile.fromFile(
                file.path,
                filename: path.basename(file.path),
                contentType:
                    MediaType('image', path.extension(file.path).substring(1)),
              ),
            ],
            'societyId': societyId,
          };
          final response = await apiClient.postFormData(
              '/api/society/$type/upload', formData);
          if (response['url'] != null) {
            onSave();
            if (context.mounted) {
              Navigator.of(context).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${type == 'icon' ? 'Icon' : 'Banner'} updated'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception('No URL returned from server');
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: colors['bg'],
      surfaceTintColor: colors['bg'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors['border']!, width: 1.5),
      ),
      title: Text(
        'Edit ${type == 'icon' ? 'Icon' : 'Banner'}',
        style: TextStyle(
          color: colors['fg'],
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        'Choose an image to upload for the society ${type == 'icon' ? 'icon' : 'banner'}.',
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
          child: Text(
            'Choose Image',
            style: TextStyle(
              color: colors['accent'],
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => _pickAndUploadImage(context),
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
  final searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoadingSearch = false;
  String? searchError;

  @override
  void dispose() {
    roleController.dispose();
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add Role',
            style: TextStyle(
              color: widget.colors['fg'],
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: widget.colors['muted'], size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close',
          ),
        ],
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
                                        final roleTitle =
                                            roleController.text.trim();
                                        if (roleTitle.isEmpty) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please enter a role title')),
                                            );
                                          }
                                          return;
                                        }

                                        try {
                                          final response =
                                              await widget.apiClient.post(
                                            '/api/society/add-role/${widget.societyId}',
                                            {
                                              'role': roleTitle,
                                              'userId': userId,
                                            },
                                          );

                                          debugPrint(
                                              'Add Role Response: $response');

                                          // ✅ Success check

                                          if (response['success'] == true) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Role added successfully')),
                                              );
                                              widget.onSave();
                                              Navigator.of(context).pop(
                                                  true); // Changed to pop with boolean success
                                            }
                                          } else {
                                            throw dio.DioException(
                                              requestOptions:
                                                  dio.RequestOptions(path: ''),
                                              response: dio.Response(
                                                requestOptions:
                                                    dio.RequestOptions(
                                                        path: ''),
                                                statusCode:
                                                    response['statusCode'] ??
                                                        400,
                                                data: {
                                                  'message':
                                                      response['message'] ??
                                                          'Unknown error'
                                                },
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            String errorMsg =
                                                'Failed to add role';
                                            if (e is dio.DioException) {
                                              if (e.response?.statusCode ==
                                                  404) {
                                                errorMsg =
                                                    'Role addition endpoint not found. Please check server configuration.';
                                              } else {
                                                errorMsg +=
                                                    ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
                                              }
                                              debugPrint(
                                                  'Dio error adding role: $errorMsg');
                                            } else {
                                              debugPrint(
                                                  'Unexpected error adding role: $e');
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

class _MinimalButton extends StatefulWidget {
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
  State<_MinimalButton> createState() => _MinimalButtonState();
}

class _MinimalButtonState extends State<_MinimalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.colors['border']!.withOpacity(0.1)
              : widget.colors['bg'],
          border: Border.all(
            color: widget.colors['border']!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: widget.colors['accent']),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.colors['accent'],
                fontWeight: FontWeight.w500,
                fontSize: 13,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatefulWidget {
  final String? roleImage;
  final String roleTitle;
  final String roleName;
  final String roleId;
  final bool showEdit;
  final Function(String, String)? onDelete;
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
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.colors['bg'],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.colors['border']!,
                    width: 1.2,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        widget.roleImage != null && widget.roleImage!.isNotEmpty
                            ? CircleAvatar(
                                radius: 32,
                                backgroundImage:
                                    NetworkImage(widget.roleImage!),
                                backgroundColor: widget.colors['border'],
                              )
                            : CircleAvatar(
                                radius: 32,
                                backgroundColor: widget.colors['border'],
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: widget.colors['muted'],
                                ),
                              ),
                        if (widget.showEdit)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => widget.onDelete
                                  ?.call(widget.roleId, widget.roleTitle),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.colors['bg'],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: widget.colors['border']!,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.roleTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.colors['fg'],
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.roleName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: widget.colors['muted'],
                        letterSpacing: -0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.colors['accent']!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.roleTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.colors['accent'],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildImageFallback(Map<String, Color> colors) {
  return Container(
    color: colors['border']!.withOpacity(0.1),
    child: Center(
      child: Icon(
        Icons.person,
        size: 40,
        color: colors['muted'],
      ),
    ),
  );
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
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.redAccent.withOpacity(_isHovered ? 0.4 : 0.3),
                      blurRadius: _isHovered ? 8 : 6,
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
