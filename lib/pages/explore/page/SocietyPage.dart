// import 'dart:developer';
// import 'package:dio/dio.dart' as dio;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:socian/features/auth/providers/auth_provider.dart';
// import 'package:socian/shared/services/api_client.dart';

// class SocietyPage extends ConsumerStatefulWidget {
//   final String societyId;
//   const SocietyPage({super.key, required this.societyId});

//   @override
//   ConsumerState<SocietyPage> createState() => _SocietyPageState();
// }

// class _SocietyPageState extends ConsumerState<SocietyPage> {
//   final _apiClient = ApiClient();
//   Map<String, dynamic>? societyData;
//   List<dynamic> posts = [];
//   int currentPage = 1;
//   int pageSize = 10;
//   bool isLoading = true;
//   bool isLoadingMore = false;
//   bool hasMore = true;
//   String? error;
//   bool isMember = false;
//   Map<String, dynamic>? authUser;
//   bool editable = false;

//   // shadcn black/white palette for dark and light mode
//   static const Color darkBg = Color(0xFF000000);
//   static const Color darkFg = Color(0xFFFFFFFF);
//   static const Color darkMuted = Color(0xFF888888);
//   static const Color darkBorder = Color(0xFF222222);
//   static const Color darkAccent = Color(0xFFFFFFFF);

//   static const Color lightBg = Color(0xFFFFFFFF);
//   static const Color lightFg = Color(0xFF000000);
//   static const Color lightMuted = Color(0xFF888888);
//   static const Color lightBorder = Color(0xFFE5E5E5);
//   static const Color lightAccent = Color(0xFF000000);

//   Map<String, Color> _getThemeColors(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return {
//       'bg': isDark ? darkBg : lightBg,
//       'fg': isDark ? darkFg : lightFg,
//       'muted': isDark ? darkMuted : lightMuted,
//       'border': isDark ? darkBorder : lightBorder,
//       'accent': isDark ? darkAccent : lightAccent,
//     };
//   }

//   @override
//   void initState() {
//     super.initState();
//     authUser = ref.read(authProvider).user;
//     fetchSocietyDetails(page: 1, append: false);
//     checkMembershipStatus();
//   }

//   Future<void> fetchSocietyDetails({int page = 1, bool append = false}) async {
//     if (widget.societyId.isEmpty) return;
//     setState(() {
//       if (page == 1) {
//         isLoading = true;
//         error = null;
//       } else {
//         isLoadingMore = true;
//       }
//     });
//     try {
//       final response = await _apiClient.get(
//         '/api/society/${widget.societyId}?page=$page&limit=$pageSize',
//       );
//       log("response $response");
//       if (response['isJoined'] == true) {
//         setState(() {
//           isMember = true;
//         });
//       }
//       final society = response['society'] as Map<String, dynamic>?;
//       final fetchedPosts = (response['posts'] ?? []) as List<dynamic>;
//       if (mounted) {
//         setState(() {
//           societyData = society;
//           if (append) {
//             posts.addAll(fetchedPosts);
//           } else {
//             posts = fetchedPosts;
//           }
//           currentPage = page;
//           hasMore = fetchedPosts.length == pageSize;
//           isLoading = false;
//           isLoadingMore = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           error = "Failed to load society details";
//           isLoading = false;
//           isLoadingMore = false;
//         });
//       }
//     }
//   }

//   Future<void> checkMembershipStatus() async {
//     try {
//       final response = await _apiClient.get('/api/user/subscribedSocieties');
//       final subscribedSocieties = response as List<dynamic>;
//       final isSubscribed = subscribedSocieties
//           .any((society) => society['_id'] == widget.societyId);
//       if (mounted) {
//         setState(() {
//           isMember = isSubscribed;
//         });
//       }
//     } catch (e) {
//       print('Error checking membership: $e');
//     }
//   }

//   Future<void> toggleMembership() async {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     try {
//       if (isMember) {
//         await _apiClient.get('/api/society/leave/${widget.societyId}');
//         if (mounted) {
//           setState(() {
//             isMember = false;
//             societyData?['totalMembers'] =
//                 (societyData?['totalMembers'] ?? 1) - 1;
//           });
//           scaffoldMessenger.showSnackBar(
//             const SnackBar(content: Text('Left society successfully')),
//           );
//         }
//       } else {
//         await _apiClient.get('/api/society/join/${widget.societyId}');
//         if (mounted) {
//           setState(() {
//             isMember = true;
//             societyData?['totalMembers'] =
//                 (societyData?['totalMembers'] ?? 0) + 1;
//           });
//           scaffoldMessenger.showSnackBar(
//             const SnackBar(content: Text('Joined society successfully')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         scaffoldMessenger.showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   void _loadMorePosts() {
//     if (!isLoadingMore && hasMore) {
//       fetchSocietyDetails(page: currentPage + 1, append: true);
//     }
//   }

//   bool get isModerator {
//     if (societyData == null || authUser == null) return false;
//     final moderators = societyData?['moderators'] as List<dynamic>? ?? [];
//     final userId = authUser?['_id']?.toString();
//     return moderators.any((mod) => mod?['_id']?.toString() == userId);
//   }

//   Future<void> _showEditNameDescriptionDialog() async {
//     final colors = _getThemeColors(context);
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final TextEditingController nameController =
//         TextEditingController(text: societyData?['name'] ?? '');
//     final TextEditingController descController =
//         TextEditingController(text: societyData?['description'] ?? '');
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: colors['bg'],
//           surfaceTintColor: colors['bg'],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: colors['border']!, width: 1.5),
//           ),
//           title: Text('Edit Society',
//               style:
//                   TextStyle(color: colors['fg'], fontWeight: FontWeight.w600)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 style: TextStyle(color: colors['fg']),
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   labelStyle: TextStyle(color: colors['muted']),
//                   filled: true,
//                   fillColor: colors['bg'],
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors['border']!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors['accent']!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: descController,
//                 style: TextStyle(color: colors['fg']),
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   labelStyle: TextStyle(color: colors['muted']),
//                   filled: true,
//                   fillColor: colors['bg'],
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors['border']!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: colors['accent']!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel',
//                   style: TextStyle(
//                       color: colors['muted'], fontWeight: FontWeight.w500)),
//               onPressed: () => Navigator.of(context).pop(false),
//             ),
//             TextButton(
//               child: Text('Save',
//                   style: TextStyle(
//                       color: colors['accent'], fontWeight: FontWeight.w600)),
//               onPressed: () async {
//                 final newName = nameController.text.trim();
//                 final newDesc = descController.text.trim();
//                 if (newName.isNotEmpty) {
//                   try {
//                     await _apiClient.put('/api/society/${widget.societyId}', {
//                       'name': newName,
//                       'description': newDesc,
//                     });
//                     await fetchSocietyDetails(page: 1, append: false);
//                     Navigator.of(context).pop(true);
//                   } catch (e) {
//                     scaffoldMessenger.showSnackBar(
//                       SnackBar(content: Text('Error: ${e.toString()}')),
//                     );
//                   }
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//     nameController.dispose();
//     descController.dispose();
//     if (result == true && mounted) {
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text('Society updated')),
//       );
//     }
//   }

//   Future<void> _showEditImageDialog({required String type}) async {
//     final colors = _getThemeColors(context);
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final TextEditingController urlController = TextEditingController(
//       text: societyData?[type] ?? '',
//     );
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: colors['bg'],
//           surfaceTintColor: colors['bg'],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: colors['border']!, width: 1.5),
//           ),
//           title: Text('Edit ${type == 'icon' ? 'Icon' : 'Banner'}',
//               style:
//                   TextStyle(color: colors['fg'], fontWeight: FontWeight.w600)),
//           content: TextField(
//             controller: urlController,
//             style: TextStyle(color: colors['fg']),
//             decoration: InputDecoration(
//               labelText: '${type == 'icon' ? 'Icon' : 'Banner'} URL',
//               labelStyle: TextStyle(color: colors['muted']),
//               filled: true,
//               fillColor: colors['bg'],
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: colors['border']!),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: colors['accent']!),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel',
//                   style: TextStyle(
//                       color: colors['muted'], fontWeight: FontWeight.w500)),
//               onPressed: () => Navigator.of(context).pop(false),
//             ),
//             TextButton(
//               child: Text('Save',
//                   style: TextStyle(
//                       color: colors['accent'], fontWeight: FontWeight.w600)),
//               onPressed: () async {
//                 final newUrl = urlController.text.trim();
//                 if (newUrl.isNotEmpty) {
//                   try {
//                     await _apiClient.put('/api/society/${widget.societyId}', {
//                       type: newUrl,
//                     });
//                     await fetchSocietyDetails(page: 1, append: false);
//                     Navigator.of(context).pop(true);
//                   } catch (e) {
//                     scaffoldMessenger.showSnackBar(
//                       SnackBar(content: Text('Error: ${e.toString()}')),
//                     );
//                   }
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//     urlController.dispose();
//     if (result == true && mounted) {
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//             content: Text('${type == 'icon' ? 'Icon' : 'Banner'} updated')),
//       );
//     }
//   }

//   Future<List<dynamic>> _searchCampusUsers(String query) async {
//     if (query.isEmpty) return [];
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     try {
//       final response = await _apiClient.get(
//         '/api/user/search-campus-users',
//         queryParameters: {'query': query},
//       );
//       return response['users'] ?? [];
//     } catch (e) {
//       String errorMsg = 'Failed to search users';
//       if (e is dio.DioException) {
//         errorMsg +=
//             ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
//         debugPrint('Dio error searching campus users: $errorMsg');
//       } else {
//         debugPrint('Unexpected error searching campus users: $e');
//       }
//       if (mounted) {
//         scaffoldMessenger.showSnackBar(
//           SnackBar(content: Text(errorMsg)),
//         );
//       }
//       return [];
//     }
//   }

//   Future<void> _addModerator(String userId) async {
//     try {
//       final response = await _apiClient.post(
//         '/api/society/add-moderator/${widget.societyId}',
//         {'userId': userId},
//       );
//       if (mounted) {
//         setState(() {
//           societyData = response['society'];
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Moderator added successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         String errorMsg = 'Failed to add moderator';
//         if (e is dio.DioException) {
//           errorMsg +=
//               ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
//           debugPrint('Dio error adding moderator: $errorMsg');
//         } else {
//           debugPrint('Unexpected error adding moderator: $e');
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMsg)),
//         );
//       }
//     }
//   }

//   Future<void> _showAddModeratorDialog() async {
//     final colors = _getThemeColors(context);
//     final searchController = TextEditingController();
//     List<dynamic> searchResults = [];
//     bool isLoadingSearch = false;
//     String? searchError;

//     try {
//       final selectedUserId = await showDialog<String>(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(
//             builder: (context, setDialogState) {
//               return AlertDialog(
//                 backgroundColor: colors['bg'],
//                 surfaceTintColor: colors['bg'],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: colors['border']!, width: 1.5),
//                 ),
//                 title: Text(
//                   'Add Moderator',
//                   style: TextStyle(
//                     color: colors['fg'],
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: searchController,
//                       style: TextStyle(color: colors['fg']),
//                       decoration: InputDecoration(
//                         labelText: 'Search campus users',
//                         labelStyle: TextStyle(color: colors['muted']),
//                         prefixIcon: Icon(Icons.search, color: colors['muted']),
//                         filled: true,
//                         fillColor: colors['bg'],
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: colors['border']!),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: colors['accent']!),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onChanged: (value) async {
//                         setDialogState(() {
//                           isLoadingSearch = true;
//                           searchError = null;
//                         });
//                         try {
//                           final results =
//                               await _searchCampusUsers(value.trim());
//                           setDialogState(() {
//                             searchResults = results;
//                             isLoadingSearch = false;
//                           });
//                         } catch (e) {
//                           setDialogState(() {
//                             isLoadingSearch = false;
//                             searchError = 'Search failed. Please try again.';
//                           });
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.maxFinite,
//                       height: 200,
//                       child: isLoadingSearch
//                           ? Center(
//                               child: CircularProgressIndicator(
//                                 color: colors['accent'],
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : searchError != null
//                               ? Center(
//                                   child: Text(
//                                     searchError!,
//                                     style: TextStyle(color: colors['muted']),
//                                   ),
//                                 )
//                               : searchResults.isEmpty
//                                   ? Center(
//                                       child: Text(
//                                         searchController.text.isEmpty
//                                             ? 'Enter a name or username'
//                                             : 'No users found',
//                                         style:
//                                             TextStyle(color: colors['muted']),
//                                       ),
//                                     )
//                                   : ListView.builder(
//                                       itemCount: searchResults.length,
//                                       itemBuilder: (context, index) {
//                                         final user = searchResults[index];
//                                         final userName =
//                                             user['name']?.toString() ??
//                                                 'Unknown';
//                                         final userId = user['_id']?.toString();
//                                         return ListTile(
//                                           leading: CircleAvatar(
//                                             radius: 16,
//                                             backgroundImage:
//                                                 user['profilePicture'] != null
//                                                     ? NetworkImage(
//                                                         user['profilePicture'])
//                                                     : null,
//                                             backgroundColor: colors['border'],
//                                             child:
//                                                 user['profilePicture'] == null
//                                                     ? Icon(Icons.person,
//                                                         size: 16,
//                                                         color: colors['muted'])
//                                                     : null,
//                                           ),
//                                           title: Text(
//                                             userName,
//                                             style: TextStyle(
//                                               color: colors['fg'],
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           subtitle: Text(
//                                             '@${user['username'] ?? 'unknown'}',
//                                             style: TextStyle(
//                                               color: colors['muted'],
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                           onTap: userId != null
//                                               ? () {
//                                                   Navigator.of(context)
//                                                       .pop(userId);
//                                                 }
//                                               : null,
//                                         );
//                                       },
//                                     ),
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     child: Text(
//                       'Cancel',
//                       style: TextStyle(
//                         color: colors['muted'],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );

//       if (selectedUserId != null && mounted) {
//         await _addModerator(selectedUserId);
//       }
//     } finally {
//       searchController.dispose();
//     }
//   }

//   Widget _buildPostListItem(Map<String, dynamic> post) {
//     final colors = _getThemeColors(context);
//     final author = post['author'];
//     final upvotes = post['upvotes'] ?? 0;
//     final downvotes = post['downvotes'] ?? 0;
//     final commentsCount = post['commentsCount'] ?? 0;
//     final title = post['title'] ?? 'Untitled';
//     final content = post['content'] ?? '';
//     final createdAt = post['createdAt'];
//     final timeAgo = createdAt != null
//         ? _timeAgo(DateTime.tryParse(createdAt) ?? DateTime.now())
//         : '';

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//       decoration: BoxDecoration(
//         color: colors['bg'],
//         border: Border(
//           bottom: BorderSide(color: colors['border']!, width: 1),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 if (author != null && author['image'] != null)
//                   CircleAvatar(
//                     radius: 16,
//                     backgroundImage: NetworkImage(author['image']),
//                     backgroundColor: colors['border'],
//                   )
//                 else
//                   Container(
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: colors['border'],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(Icons.person, size: 18, color: colors['muted']),
//                   ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     author?['name'] ?? 'Anonymous',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 15,
//                       color: colors['fg'],
//                       letterSpacing: 0,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   timeAgo,
//                   style: TextStyle(
//                     color: colors['muted'],
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                     letterSpacing: 0,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 17,
//                 color: colors['fg'],
//                 letterSpacing: 0,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (content.trim().isNotEmpty) ...[
//               const SizedBox(height: 6),
//               Text(
//                 content,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: colors['muted'],
//                   height: 1.5,
//                   fontWeight: FontWeight.w400,
//                   letterSpacing: 0,
//                 ),
//                 maxLines: 4,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//             const SizedBox(height: 18),
//             Row(
//               children: [
//                 _MinimalIconButton(
//                   icon: Icons.arrow_upward_rounded,
//                   color: colors['accent']!,
//                   onTap: () {},
//                 ),
//                 const SizedBox(width: 2),
//                 Text(
//                   '${upvotes - downvotes}',
//                   style: TextStyle(
//                     color: colors['fg'],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 _MinimalIconButton(
//                   icon: Icons.mode_comment_outlined,
//                   color: colors['muted']!,
//                   onTap: () {},
//                 ),
//                 const SizedBox(width: 2),
//                 Text(
//                   '$commentsCount',
//                   style: TextStyle(
//                     color: colors['muted'],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 _MinimalIconButton(
//                   icon: Icons.share_outlined,
//                   color: colors['muted']!,
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _timeAgo(DateTime date) {
//     final now = DateTime.now();
//     final diff = now.difference(date);
//     if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//     if (diff.inHours < 24) return '${diff.inHours}h ago';
//     if (diff.inDays < 7) return '${diff.inDays}d ago';
//     return '${date.year}/${date.month}/${date.day}';
//   }

//   Widget _buildSocietyInfo() {
//     final colors = _getThemeColors(context);
//     final bannerUrl = (societyData?['banner'] ?? '').toString();
//     final iconUrl = (societyData?['icon'] ?? '').toString();
//     final name = societyData?['name'] ?? '';
//     final description = (societyData?['description'] ?? '').toString().trim();
//     final members =
//         societyData?['totalMembers'] ?? societyData?['membersCount'] ?? 0;
//     final moderators = (societyData?['moderators'] is List)
//         ? (societyData?['moderators'] as List)
//         : [];

//     final showEdit = editable && isModerator;

//     return Column(
//       children: [
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             GestureDetector(
//               onTap:
//                   showEdit ? () => _showEditImageDialog(type: 'banner') : null,
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: colors['border'],
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(0),
//                     topRight: Radius.circular(0),
//                     bottomLeft: Radius.circular(0),
//                     bottomRight: Radius.circular(0),
//                   ),
//                   image: bannerUrl.isNotEmpty
//                       ? DecorationImage(
//                           image: NetworkImage(bannerUrl),
//                           fit: BoxFit.cover,
//                           colorFilter: ColorFilter.mode(
//                             colors['bg']!.withOpacity(0.10),
//                             BlendMode.darken,
//                           ),
//                         )
//                       : null,
//                 ),
//                 child: Stack(
//                   children: [
//                     if (bannerUrl.isEmpty)
//                       Center(
//                         child:
//                             Icon(Icons.image, color: colors['muted'], size: 60),
//                       ),
//                     if (showEdit)
//                       Positioned(
//                         right: 16,
//                         top: 16,
//                         child: _MinimalIconButton(
//                           icon: Icons.edit,
//                           color: colors['accent']!,
//                           onTap: () => _showEditImageDialog(type: 'banner'),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: -44,
//               left: 32,
//               child: GestureDetector(
//                 onTap:
//                     showEdit ? () => _showEditImageDialog(type: 'icon') : null,
//                 child: Stack(
//                   children: [
//                     iconUrl.isNotEmpty
//                         ? CircleAvatar(
//                             radius: 44,
//                             backgroundColor: colors['border'],
//                             backgroundImage: NetworkImage(iconUrl),
//                           )
//                         : CircleAvatar(
//                             radius: 44,
//                             backgroundColor: colors['border'],
//                             child: Icon(Icons.groups,
//                                 color: colors['muted'], size: 44),
//                           ),
//                     if (showEdit)
//                       Positioned(
//                         right: -2,
//                         bottom: -2,
//                         child: _MinimalIconButton(
//                           icon: Icons.edit,
//                           color: colors['accent']!,
//                           onTap: () => _showEditImageDialog(type: 'icon'),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 56),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       name,
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w700,
//                         color: colors['fg'],
//                         letterSpacing: 0,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   if (showEdit)
//                     _MinimalIconButton(
//                       icon: Icons.edit,
//                       color: colors['accent']!,
//                       onTap: _showEditNameDescriptionDialog,
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               if (description.isNotEmpty)
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         description,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: colors['muted'],
//                           height: 1.5,
//                           fontWeight: FontWeight.w400,
//                           letterSpacing: 0,
//                         ),
//                       ),
//                     ),
//                     if (showEdit)
//                       _MinimalIconButton(
//                         icon: Icons.edit,
//                         color: colors['accent']!,
//                         onTap: _showEditNameDescriptionDialog,
//                       ),
//                   ],
//                 ),
//               if (description.isNotEmpty) const SizedBox(height: 18),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Icon(Icons.group, size: 20, color: colors['muted']),
//                   const SizedBox(width: 8),
//                   Text(
//                     '$members members',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                       color: colors['muted'],
//                       letterSpacing: 0,
//                     ),
//                   ),
//                   const Spacer(),
//                   _MinimalButton(
//                     icon: isMember ? Icons.remove : Icons.add_circle,
//                     label: isMember ? 'Leave' : 'Join',
//                     colors: colors,
//                     onTap: toggleMembership,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 28),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Moderators',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: colors['fg'],
//                         letterSpacing: 0,
//                       ),
//                     ),
//                   ),
//                   if (showEdit)
//                     _MinimalIconButton(
//                       icon: Icons.add,
//                       color: colors['accent']!,
//                       onTap: _showAddModeratorDialog,
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               moderators.isNotEmpty
//                   ? SizedBox(
//                       height: 120,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: moderators.length,
//                         itemBuilder: (context, index) {
//                           final moderator = moderators[index];
//                           final modName = moderator?['name'] ?? 'Unknown';
//                           final modUsername =
//                               moderator?['username'] ?? 'unknown';
//                           final modImage = moderator?['profilePicture'];
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 12),
//                             child: Container(
//                               width: 100,
//                               decoration: BoxDecoration(
//                                 color: colors['bg'],
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: colors['border']!,
//                                   width: 1,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: colors['muted']!.withOpacity(0.2),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 24,
//                                     backgroundImage: modImage != null
//                                         ? NetworkImage(modImage)
//                                         : null,
//                                     backgroundColor: colors['border'],
//                                     child: modImage == null
//                                         ? Icon(
//                                             Icons.person,
//                                             size: 24,
//                                             color: colors['muted'],
//                                           )
//                                         : null,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     modName,
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: colors['fg'],
//                                       letterSpacing: 0,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   Text(
//                                     '@$modUsername',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400,
//                                       color: colors['muted'],
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: Text(
//                         'No moderators listed.',
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w400,
//                           color: colors['muted'],
//                           letterSpacing: 0,
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = _getThemeColors(context);
//     if (isLoading) {
//       return Scaffold(
//         backgroundColor: colors['bg'],
//         body: Center(
//           child: CircularProgressIndicator(
//             color: colors['accent'],
//             strokeWidth: 2,
//           ),
//         ),
//       );
//     }
//     if (error != null) {
//       return Scaffold(
//         backgroundColor: colors['bg'],
//         body: Center(
//           child: Text(
//             error!,
//             style: TextStyle(
//               color: colors['fg'],
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0,
//             ),
//           ),
//         ),
//       );
//     }
//     if (societyData == null) {
//       return Scaffold(
//         backgroundColor: colors['bg'],
//         body: Center(
//           child: Text(
//             'No society data found.',
//             style: TextStyle(
//               color: colors['fg'],
//               fontWeight: FontWeight.w600,
//               fontSize: 15,
//               letterSpacing: 0,
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: colors['bg'],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: colors['fg']),
//         titleSpacing: 0,
//         actions: [
//           if (isModerator)
//             PopupMenuButton<String>(
//               icon: Icon(Icons.more_vert, color: colors['fg']),
//               color: colors['bg'],
//               surfaceTintColor: colors['bg'],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 side: BorderSide(color: colors['border']!, width: 1),
//               ),
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   setState(() {
//                     editable = !editable;
//                   });
//                 }
//               },
//               itemBuilder: (BuildContext context) => [
//                 PopupMenuItem<String>(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(
//                         editable ? Icons.edit_off : Icons.edit,
//                         color: colors['accent'],
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         editable ? 'Disable Edit' : 'Enable Edit',
//                         style: TextStyle(
//                             color: colors['fg'], fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             )
//           else
//             _MinimalIconButton(
//               icon: Icons.more_vert,
//               color: colors['fg']!,
//               onTap: () {},
//             ),
//         ],
//       ),
//       body: RefreshIndicator(
//         color: colors['accent'],
//         backgroundColor: colors['bg'],
//         onRefresh: () => fetchSocietyDetails(page: 1, append: false),
//         child: CustomScrollView(
//           slivers: [
//             if (societyData?['banner'] != null &&
//                 (societyData?['banner'] as String).isNotEmpty)
//               SliverToBoxAdapter(
//                 child: Container(
//                   margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                   height: 0,
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: _buildSocietyInfo(),
//             ),
//             SliverToBoxAdapter(
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(0, 28, 0, 0),
//                 padding:
//                     const EdgeInsets.only(bottom: 10.0, left: 24, right: 24),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: colors['border']!, width: 1),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Text(
//                       'Posts',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: colors['fg'],
//                         letterSpacing: 0,
//                       ),
//                     ),
//                     const Spacer(),
//                     _MinimalButton(
//                       icon: Icons.add,
//                       label: 'Create Post',
//                       colors: colors,
//                       onTap: () {},
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             posts.isEmpty
//                 ? SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 36.0, horizontal: 24),
//                       child: Center(
//                         child: Text(
//                           'No posts yet. Be the first one to post!',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w400,
//                             color: colors['muted'],
//                             letterSpacing: 0,
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 : SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (context, index) {
//                         if (index < posts.length) {
//                           return _buildPostListItem(posts[index]);
//                         } else {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 18.0),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: colors['accent'],
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       childCount: posts.length + (hasMore ? 1 : 0),
//                     ),
//                   ),
//             if (posts.isNotEmpty && hasMore)
//               SliverToBoxAdapter(
//                 child: NotificationListener<ScrollNotification>(
//                   onNotification: (scrollInfo) {
//                     if (!isLoadingMore &&
//                         hasMore &&
//                         scrollInfo.metrics.pixels >=
//                             scrollInfo.metrics.maxScrollExtent - 100) {
//                       _loadMorePosts();
//                     }
//                     return true;
//                   },
//                   child: const SizedBox(height: 1),
//                 ),
//               ),
//             const SliverToBoxAdapter(child: SizedBox(height: 24)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MinimalIconButton extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _MinimalIconButton({
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: const BorderRadius.all(Radius.circular(8)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(7),
//           child: Icon(icon, color: color, size: 20),
//         ),
//       ),
//     );
//   }
// }

// class _MinimalButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Map<String, Color> colors;
//   final VoidCallback onTap;

//   const _MinimalButton({
//     required this.icon,
//     required this.label,
//     required this.colors,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: colors['bg'],
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: colors['border']!,
//               width: 1.2,
//             ),
//             borderRadius: BorderRadius.circular(8),
//             color: colors['bg'],
//           ),
//           child: Row(
//             children: [
//               Icon(icon, size: 18, color: colors['accent']),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: colors['accent'],
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                   letterSpacing: 0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }































import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/pages/profile/ProfilePage.dart';

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
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;
  bool isMember = false;
  Map<String, dynamic>? authUser;
  bool editable = false;

  // shadcn black/white palette for dark and light mode
  static const Color darkBg = Color(0xFF000000);
  static const Color darkFg = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFF888888);
  static const Color darkBorder = Color(0xFF222222);
  static const Color darkAccent = Color(0xFFFFFFFF);

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
      if (mounted) {
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
      print('Error checking membership: $e');
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final TextEditingController nameController =
        TextEditingController(text: societyData?['name'] ?? '');
    final TextEditingController descController =
        TextEditingController(text: societyData?['description'] ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors['bg'],
          surfaceTintColor: colors['bg'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors['border']!, width: 1.5),
          ),
          title: Text('Edit Society',
              style:
                  TextStyle(color: colors['fg'], fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: colors['fg']),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: colors['muted']),
                  filled: true,
                  fillColor: colors['bg'],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors['border']!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors['accent']!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: TextStyle(color: colors['fg']),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: colors['muted']),
                  filled: true,
                  fillColor: colors['bg'],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors['border']!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors['accent']!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: colors['muted'], fontWeight: FontWeight.w500)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Save',
                  style: TextStyle(
                      color: colors['accent'], fontWeight: FontWeight.w600)),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newDesc = descController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await _apiClient.put('/api/society/${widget.societyId}', {
                      'name': newName,
                      'description': newDesc,
                    });
                    await fetchSocietyDetails(page: 1, append: false);
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
    nameController.dispose();
    descController.dispose();
    if (result == true && mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Society updated')),
      );
    }
  }

  Future<void> _showEditImageDialog({required String type}) async {
    final colors = _getThemeColors(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final TextEditingController urlController = TextEditingController(
      text: societyData?[type] ?? '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors['bg'],
          surfaceTintColor: colors['bg'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors['border']!, width: 1.5),
          ),
          title: Text('Edit ${type == 'icon' ? 'Icon' : 'Banner'}',
              style:
                  TextStyle(color: colors['fg'], fontWeight: FontWeight.w600)),
          content: TextField(
            controller: urlController,
            style: TextStyle(color: colors['fg']),
            decoration: InputDecoration(
              labelText: '${type == 'icon' ? 'Icon' : 'Banner'} URL',
              labelStyle: TextStyle(color: colors['muted']),
              filled: true,
              fillColor: colors['bg'],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors['border']!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors['accent']!),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      color: colors['muted'], fontWeight: FontWeight.w500)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Save',
                  style: TextStyle(
                      color: colors['accent'], fontWeight: FontWeight.w600)),
              onPressed: () async {
                final newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  try {
                    await _apiClient.put('/api/society/${widget.societyId}', {
                      type: newUrl,
                    });
                    await fetchSocietyDetails(page: 1, append: false);
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
    urlController.dispose();
    if (result == true && mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text('${type == 'icon' ? 'Icon' : 'Banner'} updated')),
      );
    }
  }

  Future<List<dynamic>> _searchCampusUsers(String query) async {
    if (query.isEmpty) return [];
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final response = await _apiClient.get(
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
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return [];
    }
  }

  Future<void> _addModerator(String userId) async {
    try {
      final response = await _apiClient.post(
        '/api/society/add-moderator/${widget.societyId}',
        {'userId': userId},
      );
      if (mounted) {
        setState(() {
          societyData = response['society'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moderator added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Failed to add moderator';
        if (e is dio.DioException) {
          errorMsg +=
              ': ${e.response?.statusCode} ${e.response?.data['message'] ?? e.message}';
          debugPrint('Dio error adding moderator: $errorMsg');
        } else {
          debugPrint('Unexpected error adding moderator: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  Future<void> _showAddModeratorDialog() async {
    final colors = _getThemeColors(context);
    final searchController = TextEditingController();
    List<dynamic> searchResults = [];
    bool isLoadingSearch = false;
    String? searchError;

    try {
      final selectedUserId = await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: colors['bg'],
                surfaceTintColor: colors['bg'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors['border']!, width: 1.5),
                ),
                title: Text(
                  'Add Moderator',
                  style: TextStyle(
                    color: colors['fg'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      style: TextStyle(color: colors['fg']),
                      decoration: InputDecoration(
                        labelText: 'Search campus users',
                        labelStyle: TextStyle(color: colors['muted']),
                        prefixIcon: Icon(Icons.search, color: colors['muted']),
                        filled: true,
                        fillColor: colors['bg'],
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors['border']!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors['accent']!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) async {
                        setDialogState(() {
                          isLoadingSearch = true;
                          searchError = null;
                        });
                        try {
                          final results =
                              await _searchCampusUsers(value.trim());
                          setDialogState(() {
                            searchResults = results;
                            isLoadingSearch = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            isLoadingSearch = false;
                            searchError = 'Search failed. Please try again.';
                          });
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
                                color: colors['accent'],
                                strokeWidth: 2,
                              ),
                            )
                          : searchError != null
                              ? Center(
                                  child: Text(
                                    searchError!,
                                    style: TextStyle(color: colors['muted']),
                                  ),
                                )
                              : searchResults.isEmpty
                                  ? Center(
                                      child: Text(
                                        searchController.text.isEmpty
                                            ? 'Enter a name or username'
                                            : 'No users found',
                                        style:
                                            TextStyle(color: colors['muted']),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: searchResults.length,
                                      itemBuilder: (context, index) {
                                        final user = searchResults[index];
                                        final userName =
                                            user['name']?.toString() ??
                                                'Unknown';
                                        final userId = user['_id']?.toString();
                                        return ListTile(
                                          leading: CircleAvatar(
                                            radius: 16,
                                            backgroundImage:
                                                user['profilePicture'] != null
                                                    ? NetworkImage(
                                                        user['profilePicture'])
                                                    : null,
                                            backgroundColor: colors['border'],
                                            child:
                                                user['profilePicture'] == null
                                                    ? Icon(Icons.person,
                                                        size: 16,
                                                        color: colors['muted'])
                                                    : null,
                                          ),
                                          title: Text(
                                            userName,
                                            style: TextStyle(
                                              color: colors['fg'],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '@${user['username'] ?? 'unknown'}',
                                            style: TextStyle(
                                              color: colors['muted'],
                                              fontSize: 12,
                                            ),
                                          ),
                                          onTap: userId != null
                                              ? () {
                                                  Navigator.of(context)
                                                      .pop(userId);
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
                        color: colors['muted'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        },
      );

      if (selectedUserId != null && mounted) {
        await _addModerator(selectedUserId);
      }
    } finally {
      searchController.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (author != null && author['image'] != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(author['image']),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                        description,
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
                          final modImage = moderator?['profilePicture'];
                          final modId = moderator?['_id']?.toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: modId != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            userId: modId,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Container(
                                width: 100,
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
                            color: colors['fg'], fontWeight: FontWeight.w500),
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
            if (societyData?['banner'] != null &&
                (societyData?['banner'] as String).isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  height: 0,
                ),
              ),
            SliverToBoxAdapter(
              child: _buildSocietyInfo(),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                padding:
                    const EdgeInsets.only(bottom: 10.0, left: 24, right: 24),
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
                    const Spacer(),
                    _MinimalButton(
                      icon: Icons.add,
                      label: 'Create Post',
                      colors: colors,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            posts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 36.0, horizontal: 24),
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