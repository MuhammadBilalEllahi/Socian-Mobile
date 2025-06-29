import 'package:flutter/material.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PastPapers extends StatefulWidget {
  const PastPapers({super.key});

  @override
  _PastPapersState createState() => _PastPapersState();
}

class _PastPapersState extends State<PastPapers> {
  late Future<Map<String, dynamic>> pastPapers = Future.value({});
  Map<String, dynamic>? _cachedPastPapers;
  final ApiClient apiClient = ApiClient();
  late String id;
  String subjectName = '';
  String selectedYear = '';
  String selectedSession = '';
  String selectedType = '';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> paperTypes = [
    {'label': 'All Papers', 'value': '', 'icon': Icons.all_inclusive},
    {'label': 'Quizzes', 'value': 'QUIZ', 'icon': Icons.quiz},
    {'label': 'Assignments', 'value': 'ASSIGNMENT', 'icon': Icons.assignment},
    {'label': 'Lab Reports', 'value': 'LAB', 'icon': Icons.science},
    {'label': 'Sessionals', 'value': 'SESSIONAL', 'icon': Icons.event_note},
    {'label': 'Finals', 'value': 'FINAL', 'icon': Icons.school},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (routeArgs?.containsKey('_id') ?? false) {
      id = routeArgs!['_id'];
      if (_cachedPastPapers == null) {
        fetchPastPapers(id);
      }
    } else {
      setState(() {
        pastPapers = Future.error('Invalid route arguments or missing ID');
      });
    }
  }

  void fetchPastPapers(String id) async {
    setState(() {
      pastPapers = Future.value({'loading': true});
    });

    final String endpoint = "${ApiConstants.subjectPastpapers}/$id";
    try {
      final response = await apiClient.get(endpoint);
      setState(() {
        subjectName = response?['subjectName'] ?? '';
        _cachedPastPapers = response;
        pastPapers = Future.value(response ?? {});
      });
    } catch (e) {
      setState(() {
        pastPapers = Future.error('Failed to load past papers: $e');
      });
      _showSnackBar('Unable to load past papers. Please try again.',
          isError: true);
    }
  }

  Future<void> _launchPDF(String? pdfUrl, String paperTitle) async {
    if (pdfUrl == null) {
      _showSnackBar('This paper is not available yet', isError: true);
      return;
    }

    try {
      final downloadUrl = "${ApiConstants.pdfBaseURl}$pdfUrl";
      final Uri url = Uri.parse(downloadUrl);

      _showSnackBar('Opening paper...', isError: false);

      if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
        _showSnackBar('Unable to open paper. Please try again later.',
            isError: true);
      }
    } catch (e) {
      _showSnackBar(
          'Error opening paper. Please check your internet connection.',
          isError: true);
    }
  }

  void navigateToDiscussionPage(String id, String paperType, String subjectId) {
    Navigator.pushNamed(context, AppRoutes.discussionViewScreen,
        arguments: {'_id': id, 'paperType': paperType, 'subjectId': subjectId});
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showTypeFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: foreground,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Filter by Type',
                        style: TextStyle(
                          color: foreground,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: foreground),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: paperTypes
                          .map((type) => _buildTypeFilterOption(
                                type['label'],
                                type['value'],
                                type['icon'],
                              ))
                          .toList(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedType = '';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear Filter',
                          style: TextStyle(color: mutedForeground),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterOption(String label, String value, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedType == value;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return InkWell(
      onTap: () {
        setState(() {
          selectedType = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: border),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : mutedForeground,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : foreground,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  bool _filterPaper(Map<String, dynamic> paper) {
    if (_searchQuery.isNotEmpty) {
      final String title = paper['type']?.toString().toLowerCase() ?? '';
      final String category = paper['category']?.toString().toLowerCase() ?? '';
      if (!title.contains(_searchQuery) && !category.contains(_searchQuery)) {
        return false;
      }
    }

    if (selectedType.isNotEmpty && paper['type'] != selectedType) {
      return false;
    }

    return true;
  }

  Widget _buildPaperCard(Map<String, dynamic> paperItem) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    if (!_filterPaper(paperItem)) {
      return const SizedBox.shrink();
    }

    String paperTitle = paperItem['type'] ?? '';
    if (paperItem['category'] != null) {
      paperTitle += ' (${paperItem['category']})';
    }

    return Card(
      elevation: 2,
      color: accent,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => navigateToDiscussionPage(
            paperItem['_id'], paperItem['type'], paperItem['subjectId']),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                paperItem['type'] == 'LAB' ? Icons.science : Icons.description,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paperTitle,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                      ),
                    ),
                    if (paperItem['metadata'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye_outlined,
                              color: mutedForeground, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${paperItem['metadata']['views']}',
                            style:
                                TextStyle(color: mutedForeground, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.download_outlined,
                              color: mutedForeground, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${paperItem['metadata']['downloads']}',
                            style:
                                TextStyle(color: mutedForeground, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: mutedForeground, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: foreground),
              decoration: InputDecoration(
                hintText: 'Search papers...',
                hintStyle: TextStyle(color: mutedForeground),
                prefixIcon: Icon(Icons.search, color: mutedForeground),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: mutedForeground),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: accent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    selectedType.isNotEmpty ? Colors.blue : Colors.transparent,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: selectedType.isNotEmpty ? Colors.blue : foreground,
              ),
              onPressed: _showTypeFilterDialog,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Custom theme colors
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          subjectName.isEmpty ? 'Past Papers' : subjectName,
          style: TextStyle(
            color: foreground,
            fontSize: 18,
          ),
        ),
        backgroundColor: muted,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (selectedType.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      paperTypes.firstWhere(
                          (t) => t['value'] == selectedType)['label'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        selectedType = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: pastPapers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[400], size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load papers',
                          style: TextStyle(color: mutedForeground),
                        ),
                        TextButton(
                          onPressed: () => fetchPastPapers(id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No papers available',
                      style: TextStyle(color: mutedForeground),
                    ),
                  );
                }

                final papers = snapshot.data!['papers'] as List?;
                if (papers == null || papers.isEmpty) {
                  return Center(
                    child: Text(
                      'No papers available',
                      style: TextStyle(color: mutedForeground),
                    ),
                  );
                }

                return _buildPapersList(papers);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPapersList(List papers) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Column(
      children: [
        if (selectedType.isEmpty)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final year = papers[index]['academicYear'].toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(year),
                    selected: selectedYear == year,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedYear = selected ? year : '';
                        selectedSession = '';
                      });
                    },
                    backgroundColor: isDarkMode
                        ? const Color(0xFF27272A)
                        : const Color(0xFFF4F4F5),
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color:
                          selectedYear == year ? Colors.white : mutedForeground,
                      fontSize: 12,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              if (selectedYear.isNotEmpty &&
                  paper['academicYear'].toString() != selectedYear) {
                return const SizedBox.shrink();
              }
              return _buildYearSection(paper);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearSection(Map<String, dynamic> paper) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final papersList = paper['papers'] as List?;
    if (papersList == null || papersList.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, List> sessionPapers = {};

    for (var p in papersList) {
      if (selectedType.isNotEmpty && p['type'] != selectedType) {
        continue;
      }
      final String session = p['term'] ?? 'Other';
      sessionPapers.putIfAbsent(session, () => []).add(p);
    }

    if (sessionPapers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedType.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Academic Year ${paper['academicYear']}',
              style: TextStyle(
                color: foreground,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ...sessionPapers.entries
            .map((entry) => _buildSessionSection(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildSessionSection(String session, List papers) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final Map<String, List> typePapers = {};
    for (var p in papers) {
      String type = p['type'] ?? 'Other';
      if (type == 'SESSIONAL') {
        type = 'SESSIONAL ${p['sessionType']}';
      }
      typePapers.putIfAbsent(type, () => []).add(p);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedType.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              session,
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 14,
              ),
            ),
          ),
        ...typePapers.entries.map(
            (typeEntry) => _buildTypeSection(typeEntry.key, typeEntry.value)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTypeSection(String type, List papers) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedType.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              type,
              style: TextStyle(
                color: mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
        ...papers.map((p) => _buildPaperCard(p)),
      ],
    );
  }
}
