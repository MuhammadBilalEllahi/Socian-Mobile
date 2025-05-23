import 'package:flutter/material.dart';
import 'package:socian/shared/services/api_client.dart';

class AddQuestion extends StatefulWidget {
  final String toBeDiscussedId;
  final String? parentId;
  final Function(String) onQuestionSelected;

  const AddQuestion({
    Key? key,
    required this.toBeDiscussedId,
    this.parentId,
    required this.onQuestionSelected,
  }) : super(key: key);

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  final ApiClient _apiClient = ApiClient();
  final questionNumberOrAlphaBetController = TextEditingController();
  final partController = TextEditingController();
  final subPartController = TextEditingController();
  final questionContentController = TextEditingController();
  List<dynamic> existingQuestions = [];
  List<List<dynamic>> nestedSubQuestions = [];
  String? selectedParentQuestionId;
  List<String?> selectedSubQuestionIds = [];
  bool isLoading = true;
  bool showError = false;
  int currentLevel = 0;
  String? fullPath;

  @override
  void initState() {
    super.initState();
    _fetchExistingQuestions();
  }

  @override
  void dispose() {
    questionNumberOrAlphaBetController.dispose();
    partController.dispose();
    subPartController.dispose();
    questionContentController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingQuestions() async {
    try {
      final response = await _apiClient.post(
        '/api/discussion/parent-questions/all',
        {'toBeDiscussedId': widget.toBeDiscussedId},
      );
      setState(() {
        existingQuestions = response['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch questions: $e')),
      );
    }
  }

  Future<List<dynamic>> _fetchSubQuestions(String parentId) async {
    try {
      final response = await _apiClient.post(
        '/api/discussion/sub-questions/all',
        {
          'toBeDiscussedId': widget.toBeDiscussedId,
          'parentId': parentId,
        },
      );
      return response['data'] ?? [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch sub-questions: $e')),
      );
      return [];
    }
  }

  Future<void> _loadSubQuestionAtLevel(int level, String parentId) async {
    final subQuestions = await _fetchSubQuestions(parentId);

    setState(() {
      // Ensure the nestedSubQuestions list has enough levels
      while (nestedSubQuestions.length <= level) {
        nestedSubQuestions.add([]);
      }

      // Update the subquestions at this level
      nestedSubQuestions[level] = subQuestions;

      // Clear any selections at deeper levels
      if (selectedSubQuestionIds.length > level) {
        selectedSubQuestionIds = selectedSubQuestionIds.sublist(0, level);
        // Also clear the subquestions lists for deeper levels
        nestedSubQuestions = nestedSubQuestions.sublist(0, level + 1);
      }
    });
  }

  String _calculateFullPath(String questionNumberOrAlphaBet,
      {String? parentPath}) {
    // debugPrint("THIS IS CALCULT $questionNumberOrAlphaBet and $parentPath");
    if (parentPath == null || parentPath.isEmpty) {
      return questionNumberOrAlphaBet;
    }
    return '$parentPath.$questionNumberOrAlphaBet';
  }

  Future<void> _submitQuestion({String? parentId, int level = 0}) async {
    if (questionNumberOrAlphaBetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question number is required')),
      );
      return;
    }

    try {
      // Get parent's fullPath if it exists
      String? parentFullPath;
      if (parentId != null) {
        // Find the parent question to get its fullPath
        final allQuestions = [existingQuestions, ...nestedSubQuestions]
            .expand((x) => x)
            .toList();
        final parentQuestion = allQuestions.firstWhere(
          (q) => q['_id'] == parentId,
          orElse: () => null,
        );
        if (parentQuestion != null && parentQuestion['fullPath'] != null) {
          parentFullPath = parentQuestion['fullPath'];
          level = (parentQuestion['level'] ?? 0) + 1;
        }
      }

      final calculatedFullPath = _calculateFullPath(
        questionNumberOrAlphaBetController.text,
        parentPath: parentFullPath,
      );

      final data = {
        'toBeDiscussedId': widget.toBeDiscussedId,
        'parentId': parentId,
        // 'questionLevel': parentId == null ? 'main' : 'sub',
        'questionNumberOrAlphabet': questionNumberOrAlphaBetController.text,
        'questionContent': questionContentController.text,
        'questionLevel': level,
        'fullPath': calculatedFullPath,
      };

      if (parentId != null) {
        data['parentId'] = parentId;
      }

      final response =
          await _apiClient.post('/api/discussion/create/question', data);
      final newQuestionId = response['data']['_id'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question created successfully')),
        );
        _fetchExistingQuestions();
        if (parentId != null) {
          // Refresh the subquestions at the appropriate level
          _loadSubQuestionAtLevel(level - 1, parentId);
        }
        // Clear form
        questionNumberOrAlphaBetController.clear();
        questionContentController.clear();

        // Notify parent about the new question
        widget.onQuestionSelected(newQuestionId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create question: $e')),
      );
    }
  }

  void _showAddQuestionDialog({String? parentId, int level = 0}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(parentId == null
            ? 'Add New Question'
            : 'Add Sub-question (Level $level)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionNumberOrAlphaBetController,
              decoration: const InputDecoration(
                labelText: 'Question Number/Letter*',
                hintText: 'e.g., 5, a, i, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionContentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Question Content',
                hintText: 'Enter the question content here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitQuestion(parentId: parentId, level: level);
              // Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Helper method to truncate text safely
  String _truncateText(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '';
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
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
    final primaryColor = Theme.of(context).primaryColor;
    final errorColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: mutedForeground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.parentId == null ? 'Add New Question' : 'Add Sub-question',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Questions Section
                    Text(
                      'Main Questions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedParentQuestionId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Select Main Question',
                              labelStyle: TextStyle(color: mutedForeground),
                              filled: true,
                              fillColor: background,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: showError ? errorColor : border,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: showError ? errorColor : primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('None (Create Main Question)'),
                              ),
                              ...existingQuestions
                                  .where((q) =>
                                      q['level'] == 0 || q['level'] == null)
                                  .map((question) {
                                final questionNumber =
                                    question['questionNumberOrAlphabet'];
                                final displayText = 'Q$questionNumber';
                                final content = _truncateText(
                                    question['questionContent'], 30);

                                return DropdownMenuItem<String>(
                                  value: question['_id'],
                                  child: Tooltip(
                                    message:
                                        '$displayText: ${question['questionContent']}',
                                    child: Text(
                                      '$displayText: $content',
                                      style: TextStyle(color: foreground),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) async {
                              setState(() {
                                selectedParentQuestionId = value;
                                selectedSubQuestionIds = [];
                                nestedSubQuestions = [];
                                showError = false;
                                currentLevel = 0;
                              });

                              if (value != null) {
                                // Load first level subquestions
                                await _loadSubQuestionAtLevel(0, value);
                                widget.onQuestionSelected(value);

                                // Find the selected question to get its level
                                final selectedQuestion =
                                    existingQuestions.firstWhere(
                                  (q) => q['_id'] == value,
                                  orElse: () => {'level': 0},
                                );
                                setState(() {
                                  currentLevel =
                                      (selectedQuestion['level'] ?? 0) + 1;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showAddQuestionDialog(level: 0),
                          icon: Icon(Icons.add, color: foreground),
                          tooltip: 'Add New Main Question',
                        ),
                      ],
                    ),

                    // Nested Sub-Questions Sections
                    for (int i = 0; i < nestedSubQuestions.length; i++) ...[
                      if (nestedSubQuestions[i].isNotEmpty ||
                          i < selectedSubQuestionIds.length) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Level ${i + 1} Sub-questions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: i < selectedSubQuestionIds.length
                                    ? selectedSubQuestionIds[i]
                                    : null,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText:
                                      'Select Level ${i + 1} Sub-question',
                                  labelStyle: TextStyle(color: mutedForeground),
                                  filled: true,
                                  fillColor: background,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('None (Create Sub-question)'),
                                  ),
                                  ...nestedSubQuestions[i].map((question) {
                                    // Get parent path for hierarchical display
                                    String displayText;
                                    if (i == 0) {
                                      // First level sub-question (e.g., Q1.A)
                                      final parentQuestion =
                                          existingQuestions.firstWhere(
                                        (q) =>
                                            q['_id'] ==
                                            selectedParentQuestionId,
                                        orElse: () =>
                                            {'questionNumberOrAlphabet': ''},
                                      );
                                      final parentNumber = parentQuestion[
                                          'questionNumberOrAlphabet'];
                                      displayText =
                                          'Q$parentNumber.${question['questionNumberOrAlphabet']}';
                                    } else {
                                      // Deeper level sub-question (e.g., Q1.A.a)
                                      // Build the path from all previous selections
                                      String path = '';

                                      // Get main question
                                      final mainQuestion =
                                          existingQuestions.firstWhere(
                                        (q) =>
                                            q['_id'] ==
                                            selectedParentQuestionId,
                                        orElse: () =>
                                            {'questionNumberOrAlphabet': ''},
                                      );
                                      path =
                                          'Q${mainQuestion['questionNumberOrAlphabet']}';

                                      // Add all previous sub-questions to the path
                                      for (int j = 0; j < i; j++) {
                                        final subQ =
                                            nestedSubQuestions[j].firstWhere(
                                          (q) =>
                                              q['_id'] ==
                                              selectedSubQuestionIds[j],
                                          orElse: () =>
                                              {'questionNumberOrAlphabet': ''},
                                        );
                                        path +=
                                            '.${subQ['questionNumberOrAlphabet']}';
                                      }

                                      // Add current question
                                      displayText =
                                          '$path.${question['questionNumberOrAlphabet']}';
                                    }

                                    final content = _truncateText(
                                        question['questionContent'], 30);

                                    return DropdownMenuItem<String>(
                                      value: question['_id'],
                                      child: Tooltip(
                                        message:
                                            '$displayText: ${question['questionContent']}',
                                        child: Text(
                                          '$displayText: $content',
                                          style: TextStyle(color: foreground),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) async {
                                  // Update the selection at this level
                                  while (selectedSubQuestionIds.length <= i) {
                                    selectedSubQuestionIds.add(null);
                                  }

                                  setState(() {
                                    selectedSubQuestionIds[i] = value;
                                  });

                                  if (value != null) {
                                    // Load next level subquestions
                                    await _loadSubQuestionAtLevel(i + 1, value);
                                    widget.onQuestionSelected(value);

                                    // Find the selected question to update current level
                                    final selectedQuestion =
                                        nestedSubQuestions[i].firstWhere(
                                      (q) => q['_id'] == value,
                                      orElse: () => {'level': i + 1},
                                    );
                                    setState(() {
                                      currentLevel =
                                          (selectedQuestion['level'] ??
                                                  (i + 1)) +
                                              1;
                                    });
                                  } else {
                                    // Clear deeper levels
                                    setState(() {
                                      if (selectedSubQuestionIds.length >
                                          i + 1) {
                                        selectedSubQuestionIds =
                                            selectedSubQuestionIds.sublist(
                                                0, i + 1);
                                      }
                                      if (nestedSubQuestions.length > i + 1) {
                                        nestedSubQuestions = nestedSubQuestions
                                            .sublist(0, i + 1);
                                      }
                                      currentLevel = i + 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                final String parentId = i == 0
                                    ? selectedParentQuestionId!
                                    : selectedSubQuestionIds[i - 1]!;
                                _showAddQuestionDialog(
                                  parentId: parentId,
                                  level: i + 1,
                                );
                              },
                              icon: Icon(Icons.add, color: foreground),
                              tooltip: 'Add New Level ${i + 1} Sub-question',
                            ),
                          ],
                        ),
                      ],
                    ],

                    // Action Buttons
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Find the deepest selected question ID
                            String? targetParentId;
                            int targetLevel = 0;

                            // Check if we have any selected sub-questions
                            for (int i = selectedSubQuestionIds.length - 1;
                                i >= 0;
                                i--) {
                              if (selectedSubQuestionIds[i] != null) {
                                targetParentId = selectedSubQuestionIds[i];
                                targetLevel = i +
                                    2; // Level is 1-based and we're adding to the next level
                                break;
                              }
                            }

                            // If no sub-questions selected, check if main question is selected
                            if (targetParentId == null &&
                                selectedParentQuestionId != null) {
                              targetParentId = selectedParentQuestionId;
                              targetLevel = 1;
                            }

                            _showAddQuestionDialog(
                              parentId: targetParentId,
                              level: targetLevel,
                            );
                          },
                          icon: Icon(Icons.add, color: foreground),
                          label: Text(
                            selectedSubQuestionIds.any((id) => id != null)
                                ? 'Add Sub-question to Selected'
                                : selectedParentQuestionId != null
                                    ? 'Add Sub-question'
                                    : 'Add Main Question',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
