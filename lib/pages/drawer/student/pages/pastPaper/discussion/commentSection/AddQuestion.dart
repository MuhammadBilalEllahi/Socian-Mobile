import 'package:flutter/material.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

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
  final questionNumberController = TextEditingController();
  final partController = TextEditingController();
  final subPartController = TextEditingController();
  final questionContentController = TextEditingController();
  List<dynamic> existingQuestions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExistingQuestions();
  }

  @override
  void dispose() {
    questionNumberController.dispose();
    partController.dispose();
    subPartController.dispose();
    questionContentController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingQuestions() async {
    try {
      final response = await _apiClient.post(
        '/api/discussion/questions/all',
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

  Future<void> _submitQuestion() async {
    if (questionNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question number is required')),
      );
      return;
    }

    try {
      final data = {
        'toBeDiscussedId': widget.toBeDiscussedId,
        'questionLevel': 'main',
        'questionNumberOrAlphabet': questionNumberController.text,
        'questionContent': questionContentController.text,
      };

      if (widget.parentId != null) {
        data['parentId'] = widget.parentId!;
      }

      await _apiClient.post('/api/discussion/create/question', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create question: $e')),
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
    final primaryColor = Theme.of(context).primaryColor;

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
          else if (widget.parentId == null && existingQuestions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Parent Question (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: null,
                  decoration: InputDecoration(
                    labelText: 'Select Question',
                    labelStyle: TextStyle(color: mutedForeground),
                    filled: true,
                    fillColor: background,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None (Main Question)'),
                    ),
                    ...existingQuestions.map((question) {
                      return DropdownMenuItem<String>(
                        value: question['_id'],
                        child: Text(
                          'Q${question['questionNumberOrAlphabet']}',
                          style: TextStyle(color: foreground),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onQuestionSelected(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: mutedForeground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          Text(
            'Create New Question',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: questionNumberController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: foreground),
            decoration: InputDecoration(
              labelText: 'Question Number*',
              labelStyle: TextStyle(color: mutedForeground),
              hintText: 'e.g., 5',
              hintStyle: TextStyle(color: mutedForeground.withOpacity(0.7)),
              filled: true,
              fillColor: background,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: border),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: questionContentController,
            maxLines: 3,
            style: TextStyle(color: foreground),
            decoration: InputDecoration(
              labelText: 'Question Content',
              labelStyle: TextStyle(color: mutedForeground),
              hintText: 'Enter the question content here...',
              hintStyle: TextStyle(color: mutedForeground.withOpacity(0.7)),
              filled: true,
              fillColor: background,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: border),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Question',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
