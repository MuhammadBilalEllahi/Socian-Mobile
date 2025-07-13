import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/profile/settings/ModRequestPage.dart';
import 'package:socian/shared/services/api_client.dart';

class ModeratorsPage extends ConsumerStatefulWidget {
  const ModeratorsPage({super.key});

  @override
  ConsumerState<ModeratorsPage> createState() => _ModeratorsPageState();
}

class _ModeratorsPageState extends ConsumerState<ModeratorsPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? moderatorsData;
  List<dynamic> currentModerators = [];
  List<dynamic> previousModerators = [];
  final apiClient = ApiClient();
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getAllCampusMods();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getAllCampusMods() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await apiClient.get("/api/user/get-all-mods");
      log("____MODERATORS_____ $response ________");

      if (response['mods'] != null) {
        setState(() {
          moderatorsData = response['mods'];
          currentModerators = response['mods']['nowModUsers'] ?? [];
          previousModerators = response['mods']['prevModUsers'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No moderators found';
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching moderators: $e');
      setState(() {
        errorMessage = 'Failed to load moderators';
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildModeratorCard(Map<String, dynamic> moderator, bool isCurrent) {
    final user = isCurrent ? moderator['_id'] : moderator['userId'];
    final name = user?['name'] ?? 'Unknown';
    final username = user?['username'] ?? 'Unknown';
    final profilePicture = user?['profile']?['picture'] ??
        'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg';

    final startTime = moderator['startTime'];
    final endTime = moderator['endTime'];
    final timePeriod = moderator['timePeriod'] ?? 'Unknown';
    final reason = moderator['reason'] ?? 'No reason provided';
    final actionsDoneCount = moderator['actionsDoneCount'] ?? 0;

    // Check if this is the current user
    final auth = ref.watch(authProvider);
    final currentUserId = auth.user?['_id'];
    final moderatorUserId = user?['_id'];
    final isCurrentUser = currentUserId == moderatorUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF09090B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF27272A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFACC15),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    profilePicture,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFACC15),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFFA1A1AA),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFACC15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                color: Color(0xFF000000),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFFFACC15).withOpacity(0.2)
                      : const Color(0xFF71717A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCurrent ? 'ACTIVE' : 'FORMER',
                  style: TextStyle(
                    color: isCurrent
                        ? const Color(0xFFFACC15)
                        : const Color(0xFF71717A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Time Period Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF27272A),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: const Color(0xFFFACC15),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${timePeriod.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFFFAFAFA),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Started',
                            style: TextStyle(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(startTime),
                            style: const TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrent ? 'Ends' : 'Ended',
                            style: TextStyle(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(endTime),
                            style: const TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontSize: 14,
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
          ),

          const SizedBox(height: 12),

          // Actions and Reason
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF27272A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        size: 14,
                        color: const Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$actionsDoneCount Actions',
                        style: const TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF27272A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: const Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: const Color(0xFF71717A),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isCurrentUserMod = auth.user?['super_role'] == 'mod';

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        title: const Text(
          'Campus Moderators',
          style: TextStyle(
            color: Color(0xFFFAFAFA),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFAFAFA),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFFACC15),
            ),
            onPressed: isLoading ? null : getAllCampusMods,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFACC15),
          unselectedLabelColor: const Color(0xFFA1A1AA),
          indicatorColor: const Color(0xFFFACC15),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 8),
                  Text('Current (${currentModerators.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 16),
                  const SizedBox(width: 8),
                  Text('Previous (${previousModerators.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFACC15),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: const Color(0xFF71717A),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: getAllCampusMods,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFACC15),
                          foregroundColor: const Color(0xFF000000),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Current Moderators Tab
                    RefreshIndicator(
                      onRefresh: getAllCampusMods,
                      color: const Color(0xFFFACC15),
                      backgroundColor: const Color(0xFF09090B),
                      child: currentModerators.isEmpty
                          ? _buildEmptyState(
                              'No active moderators found',
                              Icons.person_off,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: currentModerators.length,
                              itemBuilder: (context, index) {
                                return _buildModeratorCard(
                                  currentModerators[index],
                                  true,
                                );
                              },
                            ),
                    ),

                    // Previous Moderators Tab
                    RefreshIndicator(
                      onRefresh: getAllCampusMods,
                      color: const Color(0xFFFACC15),
                      backgroundColor: const Color(0xFF09090B),
                      child: previousModerators.isEmpty
                          ? _buildEmptyState(
                              'No previous moderators found',
                              Icons.history_toggle_off,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: previousModerators.length,
                              itemBuilder: (context, index) {
                                return _buildModeratorCard(
                                  previousModerators[index],
                                  false,
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: !isCurrentUserMod
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModRequestPage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFFACC15),
              foregroundColor: const Color(0xFF000000),
              icon: const Icon(Icons.shield),
              label: const Text(
                'Become Mod',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
