import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/services/api_client.dart';

class ModActivityTab extends ConsumerStatefulWidget {
  const ModActivityTab({super.key});

  @override
  ConsumerState<ModActivityTab> createState() => _ModActivityTabState();
}

class _ModActivityTabState extends ConsumerState<ModActivityTab> {
  final _apiClient = ApiClient();
  List<dynamic> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreActivities();
    }
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get('/api/mod/my-activities',
          queryParameters: {'page': 1, 'limit': 20});

      if (response['data'] != null) {
        setState(() {
          _activities = response['data'];
          _currentPage = 1;
          _hasMoreData = response['pagination']['totalPages'] > 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No activities found';
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error loading mod activities: $e');
      setState(() {
        _errorMessage = 'Failed to load activities';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreActivities() async {
    if (!_hasMoreData || _isLoading) return;

    try {
      final response = await _apiClient.get('/api/mod/my-activities',
          queryParameters: {'page': _currentPage + 1, 'limit': 20});

      if (response['data'] != null && response['data'].isNotEmpty) {
        setState(() {
          _activities.addAll(response['data']);
          _currentPage++;
          _hasMoreData = response['pagination']['page'] <
              response['pagination']['totalPages'];
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      log('Error loading more activities: $e');
    }
  }

  Future<void> _undoActivity(
      String activityId, String activityDescription) async {
    // Show confirmation dialog
    final reason = await _showUndoDialog(activityDescription);
    if (reason == null) return;

    try {
      final response =
          await _apiClient.post('/api/mod/undo-my-activity/$activityId', {
        'reason': reason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['undoDetails'] ?? 'Activity undone successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadActivities(); // Refresh the list
      }
    } catch (e) {
      log('Error undoing activity: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to undo activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showUndoDialog(String activityDescription) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Undo Action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to undo this action?'),
              const SizedBox(height: 8),
              Text(
                activityDescription,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for undo *',
                  hintText: 'Please provide a reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(reasonController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Undo Action'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getActionDescription(String endpoint, String method) {
    // Convert API endpoints to user-friendly descriptions
    if (endpoint.contains('/teacher/reviews/feedbacks/hide')) {
      return 'Hidden Teacher Review';
    } else if (endpoint.contains('/teacher/reply/feedback/hide')) {
      return 'Hidden Teacher Feedback Reply';
    } else if (endpoint.contains('/teacher/reply/reply/feedback/hide')) {
      return 'Hidden Teacher Feedback Comment';
    } else if (endpoint.contains('/teacher/hide')) {
      return 'Hidden Teacher Profile';
    } else if (endpoint.contains('/teacher/un-hide')) {
      return 'Unhidden Teacher Profile';
    } else if (endpoint.contains('/society/hide/')) {
      return 'Hidden Society';
    } else if (endpoint.contains('/undo-my-activity/')) {
      return 'Undone Previous Action';
    } else if (endpoint.contains('/my-activities')) {
      return 'Viewed Activity Log';
    } else if (method.toUpperCase() == 'GET') {
      return 'Viewed Content';
    } else if (method.toUpperCase() == 'POST') {
      return 'Created Content';
    } else if (method.toUpperCase() == 'PUT') {
      return 'Updated Content';
    } else if (method.toUpperCase() == 'DELETE') {
      return 'Deleted Content';
    } else {
      return 'Performed Action';
    }
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isUndone = activity['isUndone'] ?? false;
    final canBeUndone = activity['canBeUndone'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isUndone ? Colors.red.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMethodColor(activity['method'] ?? '')
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity['method'] ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getMethodColor(activity['method'] ?? ''),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isUndone)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'UNDONE',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getActionDescription(
                  activity['endpoint'] ?? '', activity['method'] ?? ''),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(activity['timestamp']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    activity['campusId']?['name'] ?? 'Unknown Campus',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
            if (isUndone) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Undo Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Undone at: ${_formatDate(activity['undoneAt'])}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (activity['undoReason'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${activity['undoReason']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (canBeUndone && !isUndone) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _undoActivity(
                    activity['_id'],
                    activity['endpoint'] ?? 'Unknown action',
                  ),
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo This Action'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _activities.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _activities.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadActivities,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_activities.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No moderator activities yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your moderation actions will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadActivities,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _activities.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _activities.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return _buildActivityCard(_activities[index]);
          },
        ),
      ),
    );
  }
}
