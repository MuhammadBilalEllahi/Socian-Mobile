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
//   bool isMember = false; // Track membership status

//   // shadcn/minimal palette for dark mode
//   static const Color darkBg = Color(0xFF18181B);
//   static const Color darkFg = Color(0xFFF4F4F5);
//   static const Color darkMuted = Color(0xFF71717A);
//   static const Color darkBorder = Color(0xFF27272A);
//   static const Color darkAccent = Color(0xFF6366F1);

//   // shadcn-inspired palette for light mode
//   static const Color lightBg = Color(0xFFF4F4F5);
//   static const Color lightFg = Color(0xFF18181B);
//   static const Color lightMuted = Color(0xFF6B7280);
//   static const Color lightBorder = Color(0xFFE5E7EB);
//   static const Color lightAccent = Color(0xFF4F46E5);

//   // Helper to get theme colors based on brightness
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

//   late final authUser;
//   bool editable = false;

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
//       final society = response['society'] as Map<String, dynamic>?;
//       final fetchedPosts = (response['posts'] ?? []) as List<dynamic>;
//       setState(() {
//         societyData = society;
//         if (append) {
//           posts.addAll(fetchedPosts);
//         } else {
//           posts = fetchedPosts;
//         }
//         currentPage = page;
//         hasMore = fetchedPosts.length == pageSize;
//         isLoading = false;
//         isLoadingMore = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = "Failed to load society details";
//         isLoading = false;
//         isLoadingMore = false;
//       });
//     }
//   }

//   Future<void> checkMembershipStatus() async {
//     try {
//       final response = await _apiClient.get('/api/user/subscribedSocieties');
//       final subscribedSocieties = response as List<dynamic>;
//       final isSubscribed = subscribedSocieties
//           .any((society) => society['_id'] == widget.societyId);
//       setState(() {
//         isMember = isSubscribed;
//       });
//     } catch (e) {
//       print('Error checking membership: $e');
//     }
//   }

//   Future<void> toggleMembership() async {
//     try {
//       if (isMember) {
//         // Leave society
//         await _apiClient.get('/api/society/leave/${widget.societyId}');
//         setState(() {
//           isMember = false;
//           societyData?['totalMembers'] =
//               (societyData?['totalMembers'] ?? 1) - 1;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Left society successfully')),
//         );
//       } else {
//         // Join society
//         await _apiClient.get('/api/society/join/${widget.societyId}');
//         setState(() {
//           isMember = true;
//           societyData?['totalMembers'] =
//               (societyData?['totalMembers'] ?? 0) + 1;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Joined society successfully')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }

//   void _loadMorePosts() {
//     if (!isLoadingMore && hasMore) {
//       fetchSocietyDetails(page: currentPage + 1, append: true);
//     }
//   }

//   // Helper: check if current user is a moderator
//   bool get isModerator {
//     if (societyData == null || authUser == null) return false;
//     final moderators = societyData?['moderators'] as List<dynamic>? ?? [];
//     final userId = authUser?['_id']?.toString();
//     for (final mod in moderators) {
//       final modId = mod?['_id']?.toString();
//       if (modId != null && modId == userId) return true;
//     }
//     return false;
//   }

//   // Edit dialog for name/description
//   Future<void> _showEditNameDescriptionDialog() async {
//     final colors = _getThemeColors(context);
//     final TextEditingController nameController =
//         TextEditingController(text: societyData?['name'] ?? '');
//     final TextEditingController descController =
//         TextEditingController(text: societyData?['description'] ?? '');
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: colors['bg'],
//           title: Text('Edit Society', style: TextStyle(color: colors['fg'])),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 style: TextStyle(color: colors['fg']),
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   labelStyle: TextStyle(color: colors['muted']),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: colors['border']!),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: colors['accent']!),
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
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: colors['border']!),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: colors['accent']!),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel', style: TextStyle(color: colors['muted'])),
//               onPressed: () => Navigator.of(context).pop(false),
//             ),
//             TextButton(
//               child: Text('Save', style: TextStyle(color: colors['accent'])),
//               onPressed: () async {
//                 final newName = nameController.text.trim();
//                 final newDesc = descController.text.trim();
//                 if (newName.isNotEmpty) {
//                   try {
//                     // await _apiClient.put(
//                     //   '/api/society/${widget.societyId}',
//                     //   data: {
//                     //     'name': newName,
//                     //     'description': newDesc,
//                     //   },
//                     // );
//                     await fetchSocietyDetails(page: 1, append: false);
//                   } catch (e) {
//                     // ignore error for now
//                   }
//                 }
//                 Navigator.of(context).pop(true);
//               },
//             ),
//           ],
//         );
//       },
//     );
//     if (result == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Society updated')),
//       );
//     }
//   }

//   // Edit icon/banner
//   Future<void> _showEditImageDialog({required String type}) async {
//     final colors = _getThemeColors(context);
//     final TextEditingController urlController = TextEditingController(
//       text: societyData?[type] ?? '',
//     );
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: colors['bg'],
//           title: Text('Edit ${type == 'icon' ? 'Icon' : 'Banner'}',
//               style: TextStyle(color: colors['fg'])),
//           content: TextField(
//             controller: urlController,
//             style: TextStyle(color: colors['fg']),
//             decoration: InputDecoration(
//               labelText: '${type == 'icon' ? 'Icon' : 'Banner'} URL',
//               labelStyle: TextStyle(color: colors['muted']),
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(color: colors['border']!),
//               ),
//               focusedBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(color: colors['accent']!),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text('Cancel', style: TextStyle(color: colors['muted'])),
//               onPressed: () => Navigator.of(context).pop(false),
//             ),
//             TextButton(
//               child: Text('Save', style: TextStyle(color: colors['accent'])),
//               onPressed: () async {
//                 final newUrl = urlController.text.trim();
//                 if (newUrl.isNotEmpty) {
//                   try {
//                     // await _apiClient.put(
//                     //   '/api/society/${widget.societyId}',
//                     //   data: {type: newUrl},
//                     // );
//                     await fetchSocietyDetails(page: 1, append: false);
//                   } catch (e) {
//                     // ignore error for now
//                   }
//                 }
//                 Navigator.of(context).pop(true);
//               },
//             ),
//           ],
//         );
//       },
//     );
//     if (result == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('${type == 'icon' ? 'Icon' : 'Banner'} updated')),
//       );
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
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//       decoration: BoxDecoration(
//         color: colors['bg'],
//         border: Border(
//           bottom: BorderSide(color: colors['border']!, width: 1),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 if (author != null && author['image'] != null)
//                   CircleAvatar(
//                     radius: 15,
//                     backgroundImage: NetworkImage(author['image']),
//                     backgroundColor: Colors.transparent,
//                   )
//                 else
//                   Container(
//                     width: 30,
//                     height: 30,
//                     decoration: BoxDecoration(
//                       color: colors['border'],
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(Icons.person, size: 16, color: colors['muted']),
//                   ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     author?['name'] ?? 'Anonymous',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 14,
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
//             const SizedBox(height: 10),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//                 color: colors['fg'],
//                 letterSpacing: 0,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (content.trim().isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Text(
//                 content,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: colors['muted'],
//                   height: 1.5,
//                   fontWeight: FontWeight.w400,
//                   letterSpacing: 0,
//                 ),
//                 maxLines: 4,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//             const SizedBox(height: 14),
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
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
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
//                     fontSize: 13,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
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
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: colors['border'],
//                   image: bannerUrl.isNotEmpty
//                       ? DecorationImage(
//                           image: NetworkImage(bannerUrl),
//                           fit: BoxFit.cover,
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
//                         right: 12,
//                         top: 12,
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
//               bottom: -40,
//               left: 24,
//               child: GestureDetector(
//                 onTap:
//                     showEdit ? () => _showEditImageDialog(type: 'icon') : null,
//                 child: Stack(
//                   children: [
//                     iconUrl.isNotEmpty
//                         ? CircleAvatar(
//                             radius: 40,
//                             backgroundColor: colors['border'],
//                             backgroundImage: NetworkImage(iconUrl),
//                           )
//                         : CircleAvatar(
//                             radius: 40,
//                             backgroundColor: colors['border'],
//                             child: Icon(Icons.groups,
//                                 color: colors['muted'], size: 40),
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
//         const SizedBox(height: 50),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       name,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
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
//               const SizedBox(height: 8),
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
//               if (description.isNotEmpty) const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Icon(Icons.group, size: 20, color: colors['muted']),
//                   const SizedBox(width: 8),
//                   Text(
//                     '$members members',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: colors['muted'],
//                       fontWeight: FontWeight.w400,
//                       letterSpacing: 0,
//                     ),
//                   ),
//                   const Spacer(),
//                   _MinimalButton(
//                     icon: isMember ? Icons.remove : Icons.add,
//                     label: isMember ? 'Leave' : 'Join',
//                     colors: colors,
//                     onTap: toggleMembership,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Moderators',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: colors['fg'],
//                   letterSpacing: 0,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               if (moderators.isNotEmpty)
//                 SizedBox(
//                   height: 80,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: moderators.length,
//                     separatorBuilder: (context, index) =>
//                         const SizedBox(width: 8),
//                     itemBuilder: (context, index) {
//                       final moderator = moderators[index];
//                       final image = moderator?['profile']?['image'] ??
//                           moderator?['image'] ??
//                           '';
//                       final modName = moderator?['name'] ?? '';
//                       return Column(
//                         children: [
//                           image.toString().isNotEmpty
//                               ? CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor: colors['border'],
//                                   backgroundImage: NetworkImage(image),
//                                 )
//                               : CircleAvatar(
//                                   radius: 24,
//                                   backgroundColor: colors['border'],
//                                   child: Icon(Icons.person,
//                                       color: colors['muted'], size: 20),
//                                 ),
//                           const SizedBox(height: 4),
//                           SizedBox(
//                             width: 60,
//                             child: Text(
//                               modName,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: colors['muted'],
//                                 fontWeight: FontWeight.w400,
//                                 letterSpacing: 0,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               if (moderators.isEmpty)
//                 Text(
//                   "No moderators listed.",
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: colors['muted'],
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
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
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
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
//             "No society data found.",
//             style: TextStyle(
//               color: colors['fg'],
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0,
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: colors['bg'],
//       appBar: AppBar(
//         backgroundColor: colors['bg'],
//         elevation: 0,
//         iconTheme: IconThemeData(color: colors['fg']),
//         titleSpacing: 0,
//         title: Text(
//           societyData?['name'] ?? '',
//           style: TextStyle(
//             color: colors['fg'],
//             fontWeight: FontWeight.w500,
//             fontSize: 18,
//             overflow: TextOverflow.ellipsis,
//             letterSpacing: 0,
//           ),
//         ),
//         actions: [
//           if (isModerator)
//             PopupMenuButton<String>(
//               icon: Icon(Icons.more_vert, color: colors['fg']),
//               color: colors['bg'],
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   setState(() {
//                     editable = !editable;
//                   });
//                 }
//               },
//               itemBuilder: (context) => [
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
//                         style: TextStyle(color: colors['fg']),
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
//                   margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     image: DecorationImage(
//                       image: NetworkImage(societyData?['banner']),
//                       fit: BoxFit.cover,
//                       colorFilter: ColorFilter.mode(
//                         Colors.black.withOpacity(0.22),
//                         BlendMode.darken,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             SliverToBoxAdapter(
//               child: _buildSocietyInfo(),
//             ),
//             SliverToBoxAdapter(
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
//                 padding: const EdgeInsets.only(bottom: 10),
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
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: colors['fg'],
//                         letterSpacing: 0,
//                       ),
//                     ),
//                     const Spacer(),
//                     _MinimalButton(
//                       icon: Icons.add,
//                       label: 'Create Post',
//                       colors: colors,
//                       onTap: () {
//                         // TODO: Implement create post
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             posts.isEmpty
//                 ? SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 36.0, horizontal: 22),
//                       child: Center(
//                         child: Text(
//                           "No posts yet. Be the first one to post!",
//                           style: TextStyle(
//                             color: colors['muted'],
//                             fontSize: 14,
//                             fontWeight: FontWeight.w400,
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
//                           final post = posts[index];
//                           return _buildPostListItem(post);
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
//                     return false;
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
//       borderRadius: BorderRadius.circular(6),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(6),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(6),
//           child: Icon(icon, color: color, size: 18),
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
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
//           decoration: BoxDecoration(
//             border: Border.all(
//                 color: colors['accent']!.withOpacity(0.18), width: 1),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.transparent,
//           ),
//           child: Row(
//             children: [
//               Icon(icon, size: 17, color: colors['accent']),
//               const SizedBox(width: 7),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: colors['accent'],
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:socian/features/auth/presentation/providers/auth_provider.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
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
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;
  bool isMember = false;
  Map<String, dynamic>? authUser;
  bool editable = false;

  // shadcn/minimal palette for dark mode
  static const Color darkBg = Color(0xFF18181B);
  static const Color darkFg = Color(0xFFF4F4F5);
  static const Color darkMuted = Color(0xFF71717A);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkAccent = Color(0xFF6366F1);

  // shadcn-inspired palette for light mode
  static const Color lightBg = Color(0xFFF4F4F5);
  static const Color lightFg = Color(0xFF18181B);
  static const Color lightMuted = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightAccent = Color(0xFF4F46E5);

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

  Future<void> checkMembershipStatus() async {
    try {
      final response = await _apiClient.get('/api/user/subscribedSocieties');
      final subscribedSocieties = response as List<dynamic>;
      final isSubscribed = subscribedSocieties
          .any((society) => society['_id'] == widget.societyId);
      setState(() {
        isMember = isSubscribed;
      });
    } catch (e) {
      print('Error checking membership: $e');
    }
  }

  Future<void> toggleMembership() async {
    try {
      if (isMember) {
        await _apiClient.get('/api/society/leave/${widget.societyId}');
        setState(() {
          isMember = false;
          societyData?['totalMembers'] =
              (societyData?['totalMembers'] ?? 1) - 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Left society successfully')),
        );
      } else {
        await _apiClient.get('/api/society/join/${widget.societyId}');
        setState(() {
          isMember = true;
          societyData?['totalMembers'] =
              (societyData?['totalMembers'] ?? 0) + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined society successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
    final TextEditingController nameController =
        TextEditingController(text: societyData?['name'] ?? '');
    final TextEditingController descController =
        TextEditingController(text: societyData?['description'] ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors['bg'],
          title: Text('Edit Society', style: TextStyle(color: colors['fg'])),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: colors['fg']),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: colors['muted']),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors['border']!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors['accent']!),
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
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors['border']!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors['accent']!),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: colors['muted'])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: colors['accent'])),
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
                    ScaffoldMessenger.of(context).showSnackBar(
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
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Society updated')),
      );
    }
  }

  Future<void> _showEditImageDialog({required String type}) async {
    final colors = _getThemeColors(context);
    final TextEditingController urlController = TextEditingController(
      text: societyData?[type] ?? '',
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors['bg'],
          title: Text('Edit ${type == 'icon' ? 'Icon' : 'Banner'}',
              style: TextStyle(color: colors['fg'])),
          content: TextField(
            controller: urlController,
            style: TextStyle(color: colors['fg']),
            decoration: InputDecoration(
              labelText: '${type == 'icon' ? 'Icon' : 'Banner'} URL',
              labelStyle: TextStyle(color: colors['muted']),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors['border']!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors['accent']!),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: colors['muted'])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: colors['accent'])),
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
                    ScaffoldMessenger.of(context).showSnackBar(
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
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${type == 'icon' ? 'Icon' : 'Banner'} updated')),
      );
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: colors['bg'],
        border: Border(
          bottom: BorderSide(color: colors['border']!, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: colors['border'],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.person, size: 16, color: colors['muted']),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    author?['name'] ?? 'Anonymous',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
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
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: colors['fg'],
                letterSpacing: 0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (content.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: colors['muted'],
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 14),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 14),
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
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors['border'],
                  image: bannerUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(bannerUrl),
                          fit: BoxFit.cover,
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
                        right: 12,
                        top: 12,
                        child: _MinimalIconButton(
                          icon: Icons.edit,
                          color: Colors.black,
                          onTap: () => _showEditImageDialog(type: 'banner'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: 24,
              child: GestureDetector(
                onTap:
                    showEdit ? () => _showEditImageDialog(type: 'icon') : null,
                child: Stack(
                  children: [
                    iconUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 40,
                            backgroundColor: colors['border'],
                            backgroundImage: NetworkImage(iconUrl),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundColor: colors['border'],
                            child: Icon(Icons.groups,
                                color: colors['muted'], size: 40),
                          ),
                    if (showEdit)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: _MinimalIconButton(
                          icon: Icons.edit,
                          color: Colors.black,
                          onTap: () => _showEditImageDialog(type: 'icon'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                      color: Colors.black,
                      onTap: _showEditNameDescriptionDialog,
                    ),
                ],
              ),
              const SizedBox(height: 8),
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
                        color: Colors.black,
                        onTap: _showEditNameDescriptionDialog,
                      ),
                  ],
                ),
              if (description.isNotEmpty) const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Spacer(),
                  _MinimalButton(
                    icon: isMember ? Icons.remove : Icons.add_circle,
                    label: isMember ? 'Leave' : 'Join',
                    colors: colors,
                    onTap: toggleMembership,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Moderators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors['fg'],
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              if (moderators.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: moderators.map(
                    (moderator) {
                      final modName = moderator?['name'] ?? 'Unknown';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          modName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: colors['fg'],
                            letterSpacing: 0,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              if (moderators.isEmpty)
                Text(
                  'No moderators listed.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colors['muted'],
                    letterSpacing: 0,
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
        backgroundColor: colors['bg'],
        body: Center(
          child: Text(
            'No society data found.',
            style: TextStyle(
              color: colors['fg'],
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors['bg'],
      appBar: AppBar(
        backgroundColor: colors['bg'],
        elevation: 0,
        iconTheme: IconThemeData(color: colors['fg']),
        titleSpacing: 0,
        title: Text(
          societyData?['name'] ?? '',
          style: TextStyle(
            color: colors['fg'],
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 0,
          ),
        ),
        actions: [
          if (isModerator)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors['fg']),
              color: colors['bg'],
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
                        style: TextStyle(color: colors['fg']),
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
            SliverToBoxAdapter(
              child: _buildSocietyInfo(),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                padding: const EdgeInsets.only(bottom: 10.0),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
                          vertical: 36.0, horizontal: 16),
                      child: Center(
                        child: Text(
                          'No posts yet. Be the first one to post!',
                          style: TextStyle(
                            fontSize: 14,
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
      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors['accent']!.withOpacity(0.18),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: colors['accent']),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: colors['accent'],
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
