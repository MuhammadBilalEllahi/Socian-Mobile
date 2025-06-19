import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';

class YourSocieties extends ConsumerStatefulWidget {
  const YourSocieties({super.key});

  @override
  _YourSocietiesState createState() => _YourSocietiesState();
}

class _YourSocietiesState extends ConsumerState<YourSocieties> {
  final _apiClient = ApiClient();
  List<dynamic> _moderatedSocieties = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchModeratedSocieties();
  }

  Future<void> _fetchModeratedSocieties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(authProvider);
      final userId = auth.user?['_id'];
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in';
        });
        return;
      }

      final response = await _apiClient.get(
        '/api/user/moderated-societies',
        queryParameters: {'id': userId},
      );

      setState(() {
        _moderatedSocieties = response ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching moderated societies: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load societies';
      });
    }
  }

  Future<void> _deleteSociety(String societyId) async {
    try {
      final response = await _apiClient.post(
        '/api/society/delete/$societyId',
        {},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response['message'] ?? 'Society deleted successfully')),
      );

      await _fetchModeratedSocieties();
    } catch (e) {
      debugPrint('Error deleting society: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete society')),
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
        elevation: 0,
        title: Text(
          'Your Moderated Societies',
          style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: foreground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: mutedForeground),
                  ),
                )
              : _moderatedSocieties.isEmpty
                  ? Center(
                      child: Text(
                        'You are not moderating any societies',
                        style: TextStyle(color: mutedForeground),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _moderatedSocieties.length,
                      itemBuilder: (context, index) {
                        final society = _moderatedSocieties[index];
                        final memberCount =
                            society['totalMembers']?.toString() ?? '0';
                        return Card(
                          color: accent,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        society['name'] ?? 'Unknown Society',
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: primary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$memberCount members',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 24),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Delete Society',
                                                  style: TextStyle(
                                                      color: foreground),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete ${society['name']}? This action cannot be undone.',
                                                  style: TextStyle(
                                                      color: mutedForeground),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: primary),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteSociety(
                                                          society['_id']);
                                                    },
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  society['description'] ??
                                      'A community for enthusiasts.',
                                  style: TextStyle(color: mutedForeground),
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
